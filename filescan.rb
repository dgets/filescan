#!/usr/bin/ruby1.9.1

#little script to scan for a filename while looking down a hierarchy which
#includes looking into different archive types on the way

require 'optparse'

VERBOSE = false

#at some point the archive types should be separated into a config file from
#this script (JSON)

#$archivers = Hash.new
$archivers = { "{tgz|tar.gz}$" => "/bin/tar ztf" }

#so apparently both .length and .size work here
if (ARGV.length != 2)
    print "filescan.rb usage:\n\tfilescan.rb [target] [location] where [target]"
    print " is the string that\n\tyou're searching for, in the [location].\n"
    exit 1
else
    puts "looking for: #{ARGV[0]} in #{ARGV[1]}"
end

TARGET = ARGV[0]
LOCATION = ARGV[1]
$success = false

#check_dir(LOCATION)

def check_dir(dirspec)
    ouah = String.new

    Dir.foreach(dirspec) { |entry|
	if ((entry == ".") or (entry == ".."))
	    if (VERBOSE)
		puts "Skipping: #{dirspec}"
	    end
	    next
	end

        if (VERBOSE)
            puts "Looking at: #{dirspec}"
        end

	#directory?
	if (File.directory?(entry))
	    check_dir(entry)
	    next
	end

	#match in the present entry?
	if (/#{TARGET}/ =~ entry)
	    puts "#{entry}"
	    $success = true
	    next
	end

	#is it an archive that we support?
	$archivers.each { |spec,command|
	    if (/#{spec}/ =~ entry)
		ouah = `#{command} #{spec}`
	    end
	    if (VERBOSE)
		puts "Searching:\n#{ouah}"
	    end

	    ouah.split("\n") { |line|
		if (/#{TARGET}/ =~ line)
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
    puts "Found #{TARGET} under #{LOCATION}\n"
end

