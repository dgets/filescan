#!/usr/bin/ruby1.9.1

#little script to scan for a filename while looking down a hierarchy which
#includes looking into different archive types on the way

require 'optparse'

VERBOSE = true

#at some point the archive types should be separated into a config file from
#this script (JSON)

archivers = { "{tgz|tar.gz}$" => "/bin/tar ztf" }

#so apparently both .length and .size work here
if (ARGV.length != 2)
    print "filescan.rb usage:\n\tfilescan.rb [target] [location] where [target]"
    print " is the string that you're\n\tsearching for, in the [location].\n"
    exit 1
else
    puts "looking for: #{ARGV[0]} in #{ARGV[1]}"
end

TARGET = ARGV[0]
LOCATION = ARGV[1]

def check_dir(dirspec)
    Dir.foreach(dirspec) { |entry|
	if (VERBOSE)
	    puts "Looking at: #{dirspec}"
	end

	archivers.each { |spec,command|
	    if (/#{spec}/ =~ entry)
		ouah = `#{command} #{spec}`
	    end
	    if (VERBOSE)
		puts "Searching:\n#{ouah}\n"
	    end

	    ouah.each { |line|
		if (/#{ARGV[0]}/ =~ line)
		    puts line
		end
	    }
	}

    }
end


