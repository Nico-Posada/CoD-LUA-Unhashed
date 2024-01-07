require "json"
require "./cod-lua-functions.cr"
require "./fnv64.cr"

class Dehasher
    @localize : Hash(UInt64, String) = {} of UInt64 => String
    
    def initialize
    end

    def init_localize : Bool
        possible_json_locations : Array(String) = ["localize.json", "localize/localize.json", "../localize.json", "../localize/localize.json"]
        found_name : String | Nil = possible_json_locations.find{|path| File.exists?(path)}
        return false if found_name.nil?

        json_text : String = File.read(found_name)
        json_data : Hash(String, String) = Hash(String, String).from_json(json_text)

        @localize = json_data.transform_keys{|key| key.includes?('/') ? Fnv64.hash(key) : key.to_u64(16)}
        return true
    end

    def fix_functions(lua_file : String, funcs : Hash(UInt64, String)) : String
        lua_file.gsub(/(\w+?)\[0x([A-F\d]+)\]\(/){
            hash : UInt64 = $2.to_u64(16)
            funcs.has_key?(hash) ? "#{$1}[ \"#{funcs[hash]}\" --[[DH]] ](" : "#{$1}[ 0x#{$2} ]("
        }
    end
    
    def fix_strings(lua_file : String) : String
        lua_file.gsub(/0x([A-F\d]+)/){
            hash : UInt64 = $1.to_u64(16)
            @localize.has_key?(hash) ? "\"#{@localize[hash]}\" --[[DH]]" : $~[0]
        }   
    end
end