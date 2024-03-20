require "json"
require "./translations/functions.cr"
require "./translations/general.cr"
require "./fnv64.cr"

class Dehasher
    @localize : Hash(UInt64, String) = {} of UInt64 => String
    @@functions : CoDFunctions = CoDFunctions.new
    @@general : CoDGeneralHashes = CoDGeneralHashes.new
    
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

    def fix_functions(lua_file : String) : String
        lua_file.gsub(/(\w+?)\[0x([A-F\d]+)\]\(/){
            hash : UInt64 = $2.to_u64(16)
            @@functions.funcs.has_key?(hash) ? "#{$1}[ \"#{@@functions.funcs[hash]}\" --[[DH]] ](" : "#{$1}[ 0x#{$2} ]("
        }
    end
    
    def fix_general(lua_file : String) : String
        lua_file.gsub(/0x([A-F\d]+)/){
            hash : UInt64 = $1.to_u64(16)
            result : String = $~[0]

            if @localize.has_key?(hash)
                result = "\"#{@localize[hash]}\" --[[DH]]"
            elsif @@general.hashes.has_key?(hash)
                result = "\"#{@@general.hashes[hash]}\" --[[DH]]"
            end

            result
        }   
    end
end