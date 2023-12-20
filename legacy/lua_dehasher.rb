require "fileutils"
require "./name_dehasher.rb"

def fnv64(str)
    str = str.downcase
    hash = 0x47F5817A5EF961BA
    prime = 0x100000001B3

    str.chars.each do |c|
        hash ^= c.ord
        hash = (hash * prime) & 0xFFFFFFFFFFFFFFFF
    end

    return hash & 0x7FFFFFFFFFFFFFFF
end

# make sure theres only one argument
if ARGV.size != 1
    puts "Expected 1 argument, got #{ARGV.size}!"
    exit
end

# check to make sure the arg is a directory path
dir = ARGV.first
if !File.directory? dir
    puts "Expected arguement to be a directory!"
    exit
end

# convert strings like "C:\path\here\" to "C:/path/here"
dir = dir.tr('\\', '/').sub(/\/$/,'')

# grab a list of all paths to files ending in .dec.lua and make sure the list actually contains anything
files = Dir.glob dir + "/*.dec.lua"
if files.size == 0
    puts "Unable to find any files ending in .dec.lua in \"#{dir}\", make sure you have properly decompiled your files!"
    exit
end

# find file names within the decompiled luas
results = files.map do |file|
    text = File.read file
    text.scan /(?:require|f0_local0)\(\s\"(.+?)\"/
end

# flatten the array, take all the unique values, then populate the hash table with the cleaned up filenames
filenames = {}
results.flatten.uniq.each do |filename|
    next unless filename =~ /\./

    filename.gsub! ?., ?/
    filename += '.lua'
    hash = fnv64 filename
    filenames[hash] = filename unless filenames.has_key? hash
end

# init localize and check to make sure the user has it  
use_strings = init_localize()
if !use_strings
    print "Failed to find localize.json in your local directory! Would you like to continue? [Y/N]: "
    response = gets.chomp

    exit if response != "Y"
end

# fix all funcs and strings, then copy file to its new home
files.each_with_index do |file, i|
    text = File.read file
    text = fix_func_names text
    text = fix_str_names text if use_strings
    
    hashed = File.basename file, '.dec.lua'
    dehashed = filenames[hashed.to_i 16]
    if dehashed.nil?
        new_path = dir + "/Parsed/Hashed/" + hashed + ".lua"
        new_dir = File.dirname new_path
        FileUtils.mkdir_p new_dir unless Dir.exist? new_dir

        File.open(new_path, ?w){|f| f.write text}
    else
        new_path = dir + "/Parsed/Dehashed/" + dehashed
        new_dir = File.dirname new_path
        FileUtils.mkdir_p new_dir unless Dir.exist? new_dir

        File.open(new_path, ?w){|f| f.write text}
    end

    puts "Fixed file #{i+1} / #{files.size}"
end
