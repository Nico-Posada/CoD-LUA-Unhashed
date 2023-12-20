{% if flag?(:win32) %}
require "./util/fnv64.cr"
require "./util/cod-lua-functions.cr"
require "./util/dehashing-util.cr"

def main() : Int32
    if ARGV.size != 1
        puts "Usage: ./lua_dehasher.exe <filepath>"
        return 1
    end

    dir : String = ARGV[0]
    unless Dir.exists?(dir)
        puts "Error: #{dir} is not a directory"
        return 1
    end

    fnv : Fnv64 = Fnv64.new true
    cod : CodFunctions = CodFunctions.new

    fixed_dirname : String = dir.tr("\\", "/").sub(/\/$/,"")
    files : Array(String) = Dir.glob("#{fixed_dirname}/*.dec.lua")
    if files.size == 0
        puts "Unable to find any files ending in .dec.lua in \"#{dir}\", make sure you have properly decompiled your files!"
        return 1
    end

    puts "Decompiled files found to analyze: #{files.size}"

    # find file names within the decompiled luas
    results : Array(String) = files.flat_map do |file|
        lua_file : String = File.read(file)
        lua_file.scan(/(?:require|f0_local0)\(\s\"(.+?)\"/).map{|m| m[1]}
    end

    # populate the hash table with the cleaned up filenames
    filenames : Hash(UInt64, String) = {} of UInt64 => String
    results.each do |filename|
        next unless filename =~ /\./

        fixed_filename : String = filename.gsub(/\./, "/") + ".lua"
        hash : UInt64 = fnv.hash(fixed_filename)
        filenames[hash] = fixed_filename unless filenames.has_key?(hash)
    end

    puts "Number of possible Lua file names: #{filenames.size}"

    dehash : Dehasher = Dehasher.new
    json : Bool = dehash.init_localize()
    if !json
        print "Failed to find localize.json in your local directory! Would you like to continue? [Y/N]: "
        user_input : String = gets || ""

        return 1 unless user_input.upcase[0] == 'Y'
    end

    # vars for printing progress
    cur_progress : Float64 = 0
    progress_len : Int32 = 20

    puts "\nBeginning dehashing process..."
    print "Progress: [#{"." * progress_len}]#{"\b" * (progress_len + 1)}"

    # fix all funcs and strings, then copy file to its new home
    files.each_with_index do |file, i|
        lua_file = File.read(file)
        lua_file = dehash.fix_functions(lua_file, cod.funcs)
        lua_file = dehash.fix_strings(lua_file) if json
        
        hashed_filename : String = File.basename(file, ".dec.lua")
        hash : UInt64 = hashed_filename.to_u64(16)
        if !filenames.has_key?(hash)
            new_path : String = dir + "/Parsed/Hashed/" + hashed_filename + ".lua"
            new_dir : String = File.dirname(new_path)
            Dir.mkdir_p(new_dir) unless Dir.exists?(new_dir)

            File.open(new_path, "w"){|f| f.print(lua_file)}
        else
            new_path : String = dir + "/Parsed/Dehashed/" + filenames[hash]
            new_dir : String = File.dirname(new_path)
            Dir.mkdir_p(new_dir) unless Dir.exists?(new_dir)

            File.open(new_path, "w"){|f| f.print(lua_file)}
        end

        temp_progress : Float64 = (i + 1) * 100.0 / files.size
        if temp_progress - cur_progress >= 100.0 / progress_len
            cur_progress += 100.0 / progress_len
            print "#"
        end
    end

    puts "\n\nFinished!"
    return 0
end

exit(main())
{% else %}
puts """This build was made for Windows only.
You can try to compile with Linux (the only other supported system),
but this project was only made with Windows in mind"""
{% end %}