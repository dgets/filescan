#!/usr/bin/ruby1.9.1

#little script to scan for a filename while looking down a hierarchy which
#includes looking into different archive types on the way

require 'optparse'

VERBOSE = false
DEBUGGING = true

#at some point the archive types should be separated into a config file from
#this script (JSON)

#$archivers = Hash.new
$archivers = { "{tgz|tar.gz}$" => "/bin/tar ztf",
	       "{tar.bz2}$" => "/bin/tar jtf" }

#so apparently both .length and .size work here
if (ARGV.length != 2)
    print "filescan.rb usage:\n\tfilescan.rb [target] [location] where [target]"
    print " is the string that\n\tyou're searching for, in the [location].\n"
    exit 1
elsif (VERBOSE)
    puts "looking for: #{ARGV[0]} in #{ARGV[1]}"
end

TARGET = ARGV[0]
LOCATION = ARGV[1]
ORIGLOC = Dir.pwd

$success = false

def check_dir(dirspec)
    ouah = String.new

    if (DEBUGGING)
	puts "Entering #{dirspec}"
    end
    Dir.chdir(dirspec)
    if (DEBUGGING)
	puts "Entered #{Dir.pwd}"
    end

    Dir.foreach(dirspec) { |entry|
	if ((/^\.$/ =~ entry) or (/^\.\.$/ =~ entry))
	    if (VERBOSE or DEBUGGING)
		puts "Skipping: #{dirspec}"
	    end
	    next
	end

        if (VERBOSE)
            puts "Looking at: #{dirspec}"
        end

	#directory?
	if (File.directory?(entry))
	    if (DEBUGGING)
		puts "Recursing to #{entry}"
	    end

	    check_dir(entry)
	    next
	end

	#match in the present entry?
	if (entry =~ /#{TARGET}/)
	    puts "#{entry}"
	    $success = true
	    next
	end

	#is it an archive that we support?
	$archivers.each { |spec,command|
	    if (DEBUGGING)
		puts "spec: #{spec}, command: #{command}"
	    end
	    if (entry =~ /#{spec}/)
		puts "Spawning: #{command}"
		ouah = `#{command} #{spec}`
	    end
	    if (VERBOSE)
		puts "Searching:\n#{ouah}"
	    end

	    ouah.split("\n") { |line|
		if (line =~ /#{TARGET}/)
		    puts "#{line}"
		    $success = true
		end
	    }
	}
    }

    if ($success == true)
	return true
    end
end

if (check_dir(LOCATION))
    puts "Found #{TARGET} under #{LOCATION}"
else
    puts "Was unable to find #{TARGET} under #{LOCATION}"
end

