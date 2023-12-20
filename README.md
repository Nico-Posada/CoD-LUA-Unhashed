# CoD Lua Dehasher
This is a program that's able to take Call of Duty's decompiled Lua files, and dehash about 98% of their file names while also dehashing many strings and function names.

**BIG OVERHAUL UPDATE**:<br>
I updated this project to use [Crystal](https://crystal-lang.org) instead of Ruby. If you look at the code between the old version (still in the legacy folder) and the new version, you'll notice that the code looks somewhat similar. That's because Crystal is, in simple terms, just a compiled Ruby. This makes the script run much faster along with the code being a lot safer now! I also changed how the localize JSON should be structed along with a few minor bug-fixes.

# Requirements
To be able to run the program you will not need to install anything. To compile the program, you need to install `Crystal` ([Windows Install](https://crystal-lang.org/install/on_windows/)) and `GCC`.

# Before Running
You must decompile your Lua files using JariK's Lua decompiler found [here](https://github.com/JariKCoding/CoDLuaDecompiler). There is a slight flaw in the code where hashes are truncated to 60 bits when they shouldn't be truncated at all. **THIS FLAW MUST BE FIXED FOR THE DEHASHER TO RUN PROPERLY FOR CERTAIN FEATURES**

# Usage
In the command line, type the following:
`./lua_dehasher.exe <path>`
where `path` is the path to your directory holding all of your Lua files.<br>**OR**<br>
Drag and drop your folder of Lua files onto the exe file and it'll begin execution.

You'll also need a localize.json file (a default one can be found in the `localize` directory in this repository). When running the program, make sure to have this localize.json file in the same directory as the executable. Although the JSON isn't required to actually run the program, it still helps to make the final LUA file outputs much cleaner.

# What to Expect
When to dehasher finishes, you'll notice a new directory named `Parsed` appear in the original directory you passed to the program. This will contain 2 subdirectories named `Hashed` and `Dehashed`. As the name suggests, Hashed contains all the files with names that could not be dehashed, and Dehashed contains all the files with names that were successfully dehashed. Upon opening any of the Lua files, you'll notice many strings marked with a `--[[DH]]` which means that those were hashed strings that the program dehashed.

# Compiling
I have provided a `build.bat` file. After installing the requirements, run `build.bat`, and go to the `build` directory. The executable will be there.
