#!/usr/bin/env ruby
#
# Author: Riccardo Orizio
# Date: Tue 30 May 2017 
# Description: Java Mergeroo
#

require 'fileutils'
require 'logger'

class Mergeroo
	LOCAL_DIR = "./"

	def initialize( debug_level )
		@log = Logger.new( STDERR, level: debug_level )
	end

	def cleanup_file( filename )
		result = "" 
		# Removing the import lines from the result 
		File.foreach( filename ) do |line| 
			# Excluding only the local imports 
			if line.include?( "import" ) then 
				if line.include?( " java." ) then 
					result += line 
				end 
			else 
				result += line 
			end 
		end 
		result.gsub!( /^package .*/, "" )
		return result 
	end

	def include_file( filename )
		# Checking if the file to be imported is correctly parsed or if it
		# exists
		if File.file?( filename ) then
			content = cleanup_file( filename )

			content.gsub!( /public (abstract )?(class|enum|interface)/, '\1\2' )

			return content
		else
			@log.fatal "Problem with an import file '#{filename}'"
			exit
		end
	end

	def merge( filename )
		# Reading the main file from input
		if filename.nil? then
			@log.error "Need a file to start parsing."
		elsif !File.file?( filename ) then
			@log.error "Can't find the file '#{filename}'"
		else
			# Looking for import in the file
			result = cleanup_file( filename )

			# Adding the file in the same package as the file submitted
			# Since the file is part of only one package, I take the first item from the
			# array given as result of the scan

			# Creating the base_path of the file, adding a reference to the local
			# folder if no reference is given
			base_path = File.dirname( filename )
			pre_base = ( base_path.start_with?( "/", "./", "../" ) ? "" : LOCAL_DIR ) 
			base_path = "#{pre_base}#{base_path}"

			# Creating an array containing the imports to do
			to_import = Array.new
			# Self package
			to_import.push( File.read( filename ).scan( /package (.*);/ ).flatten.first.concat( ".*" ) )
			# Imports
			to_import.push( File.read( filename ).scan( /import ((?!java).*);/ ) )
			# Transforming info in file paths
			to_import = to_import.flatten.map{ |x| x.gsub( ".", "/" ).concat( ".java" ) }

			# Taking the real base path knowing from where I am starting using the
			# package information
			base_path = base_path[ 0...base_path.index( File.dirname( to_import[ 0 ] ) ) ]

			# Reading all local import files, excluding the java ones
			to_import.each do |file|
				import_filename = "#{base_path}#{file}"

				# Checking if all names are specified or if the whole package is
				# required
				if import_filename.include?( "*" ) then
					@log.debug "Full package required '#{import_filename}'"

					Dir[ import_filename ].each do |package_file|
						# Excluding the file received as input to the list of imports
						if package_file != "#{pre_base}#{filename}" then
							result += include_file( package_file )
							@log.debug "\tAdded '#{File.basename( package_file )}'"
						end
					end
				else
					# It is a single file, I will include it
					result += include_file( import_filename )
					@log.debug "\tAdded '#{File.basename( import_filename )}'"
				end

			end

			# Output everything to stdout, let the user redirect to file.
			@log.info "Mergoo'd file (๑˃̵ᴗ˂̵)و"
			return result
		end
	end
end

if __FILE__ == $PROGRAM_NAME then
	puts Mergeroo.new(:info).merge( ARGV[ 0 ] )
end
