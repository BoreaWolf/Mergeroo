#!/usr/bin/env ruby
#
# Author: Riccardo Orizio
# Date: Tue 30 May 2017 
# Description: Java Mergeroo
#

def include_file( filename )
	# Checking if the file to be imported is correctly parsed or if it
	# exists
	if File.file?( filename ) then
		content = File.read( filename )

		# I can't do this on a single line because if nothing is found it
		# returns nil and then tries to work on it
		content.gsub!( /public (abstract )?(class|enum|interface)/, '\1\2' )
		content.gsub!( /package .*/, "" )
		
		return( content )
	else
		puts "Problem with an import file '#{filename}'"
		exit
	end
end

# Reading the main file from input
if ARGV[ 0 ].nil? then
	puts "Need a file to start parsing."
elsif !File.file?( ARGV[ 0 ] ) then
	puts "Can't find the file '#{ARGV[ 0 ]}'"
else
	# Looking for import in the file
	result = ""

	# Removing the import lines from the result
	File.foreach( ARGV[ 0 ] ) do |line|
		# Excluding only the local imports
		if line.include?( "import" ) then
			if line.include?( " java." ) then
				result += line
			end
		else
			result += line
		end
	end

	# Reading all local import files, excluding the java ones
	File.read( ARGV[ 0 ] ).scan( /import ((?!java).*);/ ).flatten.each do |file|
		# Getting the file name and adding the dirname to it
		filename = file.gsub( ".", "/" ).concat( ".java" )
		# Creating the base_path of the file, adding a reference to the local
		# folder if no reference is given
		base_path = File.dirname( ARGV[ 0 ] )
		base_path = "./#{base_path}" unless base_path.start_with?( "/", "./", "../" )
		base_path = base_path[ 0..base_path.index( File.dirname( filename ) )-1 ]
		filename = base_path.concat( filename )

		# Checking if all names are specified or if the whole package is
		# required
		if filename.include?( "*" ) then
			puts "Full package required '#{filename}'"

			Dir[ filename ].each do |package_file|
				result += include_file( package_file )
			end
		else
			# It is a single file, I will include it
			result += include_file( filename )
		end

	end
	
	output_filename = File.basename( ARGV[ 0 ], ".java" ).concat( ".mergeroo.java" )
	File.write( output_filename, result )

	puts "Created merged file '#{output_filename}' (๑˃̵ᴗ˂̵)و"
end

