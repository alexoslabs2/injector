### README ####

Injector a.k.a tr4c1l0rds is a tool to run simultaneous sql injections attacks anonymously.

### How do I get set up? ###

git clone git.ibliss.intranet:alexandro.silva/injector.git

cd injector

./setup.sh

### Help ###

./injector.sh -h

Usage: ./injector.sh -u [TARGET] [OPTIONS]

OPTIONS:

	-l | --list	List all existent containers
	-u | --url	 Set target url to be tested (e.g. injector -u www.example.com)
	-f | --file	 Set a file containing a list of targets (e.g. injector -f targets.txt)
	-d | --database	 Set the target database (e.g. injector -d <database> 
	-t | --table	 Set the target table (e.g. injector -d <database> -t <table>)
	-r | --post	Set the POST request parameters (e.g -r param1&param2 or -r POST file request)
	-s | --stop	Stop the specified container (e.g. injector -s <container_name>) or use -s all to stop all containers
	-o | --logs	Show the container log
	-p | --dump	Dump the data
	-n | --name	Choose a name for you sqlmap container (e.g. injector -n target)
	-a | --stats	Display the container's statistics
	-h | --help	Print this help


### Videos ###


##### Let's Hack #####

https://asciinema.org/a/m1S46KsIrvGbZqwDoZ14Qkvc6

##### List tables #####

https://asciinema.org/a/581sQV97F0tfTMlrXisjtQmY3

##### Dump #####

https://asciinema.org/a/3XAkDcYrIlAupNvQo6v3bWkad

##### Post Request #####

https://asciinema.org/a/LjDXu4Njzn5TlMP8LmyysZ3P1

##### Targets file, Statistics and Stop Containers #####

https://asciinema.org/a/AzbDB86JGAsDH7a2C4XJHLydY
