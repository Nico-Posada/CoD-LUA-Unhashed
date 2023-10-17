# Overview
This is a script I was able to whip together to make analyzing the game's LUA files a much better experience.

It is able to find and properly get the plaintext strings of many:
 - file names
 - function names
 - (hashed) strings

# Requirements
You need to install Ruby for this, I don't use any external libraries/gems so a clean install of Ruby should work just fine.

# Before Using the Script
You must decompile your LUA files using JariK's LUA decompiler found [here](https://github.com/JariKCoding/CoDLuaDecompiler). There is a slight flaw in the code where hashes are truncated to 60 bits when they shouldn't be truncated at all, so I may have to make a fork in the future to fix that.

# Usage
In the command line, type the following:
`ruby lua_dehasher.rb <path>`

path is the path to your directory holding all of your LUA files

# Notice
This code may be a bit buggy at the moment as I put the whole thing together in a couple of hours. I plan on making my explanations a bit better and improving my code in the future, but I just wanted to get this out there.
