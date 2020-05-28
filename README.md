### Injector a.k.a Tr4c1l0rds ####

Injector a.k.a tr4c1l0rds is a tool to run simultaneous sql injections attacks anonymously using containers. 

### How do I get set up? ###

##### Linux

`git clone https://github.com/iblisslabs/injector.git`

`cd injector`

`./setup.sh`


##### Mac

Download Docker from [Docker Install](https://store.docker.com/editions/community/docker-ce-desktop-mac) if you don't have it yet!

`git clone https://github.com/iblisslabs/injector.git`

`cd privoxy`

`sudo docker build -t alexoscorelabs/privoxy .`

`cd ../sqlmap`

`sudo docker build -t alexoscorelabs/sqlmap .`

### Help ###

./injector.sh -h

Usage: ./injector.sh -u [TARGET] [OPTIONS]

Usage: ./injector.sh [OPTIONS]

OPTIONS:

	-l | --list	List all existent containers
	-e | --exited   Lista exited containers
	-u | --url	 Set target url to be tested (e.g. injector -u www.example.com)
	-f | --file	 Set a file containing a list of targets (e.g. injector -f targets.txt)
	-d | --database	 Set the target database (e.g. injector -d <database> 
	-t | --table	 Set the target table (e.g. injector -d <database> -t <table>)
	-r | --post	Set the POST request parameters (e.g -r param1&param2 or -r POST file request)
	-s | --stop	Stop the specified container (e.g. injector -s <container_name>) or use -s all to stop all containers
	-o | --logs	Show the container log
	-p | --dump	Dump the data
	-n | --name	Choose a name for you sqlmap container (e.g. injector -u TARGET -n INSTANCENAME)
	-a | --stats	Display the container's statistics
	-i | --update   Update Injector
	-h | --help	Print this help

### Videos ###

![alt-text](https://github.com/alexoslabs2/injector/blob/master/examples/example1.gif)

![alt-text](https://github.com/alexoslabs2/injector/blob/master/examples/example2.gif)
