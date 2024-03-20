{% if flag?(:win32) %}
require "./util/fnv64.cr"
require "./util/dehashing_util.cr"

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

    # change a path like 'C:\path\to\somwhere\' to 'C:/path/to/somwhere'
    fixed_dirname : String = dir.tr("\\", "/").sub(/\/$/, "")

    # grab all lua files that need fixing and make sure there are any at all
    files : Array(String) = Dir.glob("#{fixed_dirname}/*.dec.lua")
    if files.size == 0
        puts "Unable to find any files ending in .dec.lua in \"#{dir}\", make sure you have properly decompiled your files!"
        return 1
    end

    puts "Decompiled files found to analyze => #{files.size}"

    # find file names within the decompiled luas
    results : Array(String) = files.flat_map do |file|
        lua_file : String = File.read(file)
        lua_file.scan(/(?:require|f0_local0|discard|AddRequirePath)\(\s(?:0x[A-F\d]{1,16},\s)?\"(.+?)\"/).map{|m| m[1]}
    end

    # add one straggler that isn't found anywhere but we know exists
    results << "ui.LUIStartup"

    # create and populate the hash table with the cleaned up filenames
    filenames : Hash(UInt64, String) = {} of UInt64 => String
    results.each do |filename|
        next unless filename.includes?('.')

        fixed_filename : String = filename.tr(".", "/") + ".lua"
        hash : UInt64 = Fnv64.hash(fixed_filename)
        filenames[hash] = fixed_filename unless filenames.has_key?(hash)
    end

    puts "Number of possible lua file names => #{filenames.size}"

    # search for localize json and parse
    dehash : Dehasher = Dehasher.new
    localize_set_up : Bool = dehash.init_localize()

    # if it doesnt exist, prompt the user to see if they'd like to continue
    unless localize_set_up
        print "Failed to find localize.json in your local directory! Would you like to continue? [Y/N]: "
        user_input : String = gets || "N"

        return 1 unless user_input.upcase[0] == 'Y'
    end

    # vars for printing progress
    cur_progress : Float64 = 0
    progress_len : Int32 = 20

    # vars for data output at the end
    dehashed_files : Int32 = 0
    hashed_files : Int32 = 0

    # set up the progress bar output
    puts "\nBeginning dehashing process..."
    print "Progress: [#{"." * progress_len}]#{"\b" * (progress_len + 1)}"

    files.each_with_index do |file, i|
        # fix all function names and strings
        lua_file = File.read(file)
        lua_file = dehash.fix_functions(lua_file)
        lua_file = dehash.fix_general(lua_file) if localize_set_up
        
        # using the hash of the filename, check to see if we were able to find the plaintext filename anywhere
        hashed_filename : String = File.basename(file, ".dec.lua")
        hash : UInt64 = hashed_filename.to_u64(16)

        # figure out full file path
        new_path = dir + "/Parsed/"
        if filenames.has_key?(hash)
            new_path += "Dehashed/" + filenames[hash]
            dehashed_files += 1
        else
            new_path += "Hashed/" + hashed_filename + ".lua"
            hashed_files += 1
        end

        # create directory if it doesnt exist and write file to path
        new_dir = File.dirname(new_path)
        Dir.mkdir_p(new_dir) unless Dir.exists?(new_dir)
        File.open(new_path, "w"){|f| f.print(lua_file)}

        # update progress bar
        temp_progress : Float64 = (i + 1) * 100.0 / files.size
        if temp_progress - cur_progress >= 100.0 / progress_len
            cur_progress += 100.0 / progress_len
            print "#"
        end
    end

    puts "\n\nFilenames fixed         => #{dehashed_files}", "Filenames unable to fix => #{hashed_files}", "\nDone!"
    return 0
end

exit main
{% else %}
puts """This build was made for Windows only.
You can try to compile with another system,
but this project was only made with Windows in mind"""
{% end %}
