#!/usr/bin/env ruby

=begin
	Injector a.k.a Tr4c1l0rds
	@authors: alexos,
	         n3k00n3,
	         UserX.
	@version: 0.1
	@date: 12/04/2018
=end

require 'getoptlong'
require_relative 'docker_module'
require_relative 'injector_module'

class Injector
	include DockerModule
	include InjectorModule

	def initialize
		@volume ="$HOME/sqlmap/:/root/.sqlmap"
		@docker_network="172.18.0.0/16"
		@level = "5"
		@risk = "3"
		@more_options_to_attack = ""
		@sqlmap_args = Array.new
		@sqlmap_hash_args = Hash.new
		@tamper = "base64encode"
		@timesec = "20"
        @url_file=""

        handleOptions

	end

	def handleOptions
		@opts = GetoptLong.new(
	      ['--help',        '-h', GetoptLong::NO_ARGUMENT],
	      ['--url',			'-u', GetoptLong::REQUIRED_ARGUMENT],
          ['--file',        '-f', GetoptLong::REQUIRED_ARGUMENT],
	      # Plural options to get all section
	      ['--tables', 		'-t', GetoptLong::NO_ARGUMENT],
	  	  ['--dbs',			'-d', GetoptLong::NO_ARGUMENT],
	  	  ['--columns',	 	'-c', GetoptLong::NO_ARGUMENT],
	  	  ['--dumpall', 	'-A', GetoptLong::NO_ARGUMENT],
	  	  # singular options require arguments
	  	  ['--db', 			'-D', GetoptLong::REQUIRED_ARGUMENT],
	  	  ['--table', 	 	'-T', GetoptLong::REQUIRED_ARGUMENT],
	  	  ['--collumn', 	'-C', GetoptLong::REQUIRED_ARGUMENT],
	  	  ['--dump', 	 	'-g', GetoptLong::REQUIRED_ARGUMENT],
	  	  ['--logs', 		'-o', GetoptLong::REQUIRED_ARGUMENT],
	  	  ['--stats', 		'-a', GetoptLong::NO_ARGUMENT],
	  	  ['--stop',		'-s', GetoptLong::REQUIRED_ARGUMENT],
	  	  ['--list',		'-l', GetoptLong::NO_ARGUMENT]
	    )

	    @optn = 0
	    @opts.each do |opt, arg|
		    @optn += 1
                case opt
                when '--help'
                    help

                when '--url'
                    @url = true
                    @target = arg

                when '--file'
                    @target = arg
                    @url_file = arg

                when '--tables'
                    @sqlmap_args.push("--tables")

                when '--dbs'
                    @sqlmap_args.push("--dbs")

                when '--columns'
                    @sqlmap_args.push("--columns")

                when '--dump'
                    @dump = true
                    @dump_database = arg

                when '--dumpall'
                    @dump_all = true

                when '--logs'
                    log_containers(arg)

                when '--stats'
                    stats_containers
                    exit 0

                when '--list'
                    list_containers
                    exit 0

                when '--stop'
                    stop_containers(arg)

                when '--db'
                    @database = true
                    @database_name = arg

                when '--table'
                    @table = true
                    @table_name = arg

                when '--column'
                    @column = true
                    @column_name = arg

                else
                    usage
                end
		end
		usage if @optn == 0
		configAditionalParams
	end

	# Show usage
	def usage
	    puts """./injector.rb [ -u <url> <OPTIONS>]
	    		example: ./injector -u https://TargetSite.com --dbs
	    		example: ./injector -u https://TargetSite.com -D database_name --tables
	    		example: ./injector -u https://TargetSite.com -D database_name -T table_name --columns
        """
	    exit 0
	end

	# Show help
	def help
		puts """Usage:
#{$0} [ -u <url> <OPTIONS>]
    OPTIONS:
    -l\t--list\tList all existent containers
    -u\t--url\tSet target url to be tested (e.g. injector -u www.example.com)
    -f\t--file\tSet a file containing a list of targets (e.g. injector -f targets.txt)
    -d\t--database\tSet the target database (e.g. injector -d <database>
    -t\t--table\tSet the target table (e.g. injector -d <database> -t <table>)
    -r\t--post\tSet the POST request parameters (e.g -r param1&param2 or -r POST file request)
    -s\t--stop\tStop the specified container (e.g. injector -s <container_name>) or use -s all to stop all containers
    -o\t--logs\tShow the container log
    -p\t--dump\tDump the data
    -n\t--name\tChoose a name for you sqlmap container (e.g. injector -n target)
    -a\t--stats\tDisplay the container's statistics
    -h\t--help\tPrint this help
        """
		exit 0
	end

    def configAditionalParams
  		@sqlmap_hash_args["-D"] = @database_name if @database_name
  		@sqlmap_hash_args["-T"] = @table_name if  @table_name
  		@sqlmap_hash_args["-C"] = @column_name if  @column_name

        if !@url and !@url_file
            STDERR.puts "[-] no target especified, please use -u <url> or -f <file targets>\n"
            exit 1
        end

    end

    def run
        # defined on DockerModule
  		check_optional_args
    	run_docker_containers
    end

end
