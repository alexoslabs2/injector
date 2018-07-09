#!/bin/bash
#Injector a.k.a tr4c1l0rds
#Authors: @alexos @alacerda


#-----------------------------
#       Terminal colors
#-----------------------------
BLUE="\e[00;34m"
GREEN="\e[00;32m"
CYAN="\e[0;31m"
END="\e[00m"

#-----------------------------
#       Variables
#-----------------------------
VOLUME="$HOME/.sqlmap/:/root/.sqlmap"
INST="$HOME/.instances"
THREADS=$(lscpu | grep ^CPU\(s\) | sed s/\ //g | cut -d":" -f 2)
CID=""
DATA=$2
USERAGENT="--random-agent"
LEVEL="5"
RISK="3"
FILE=""
DATABASE=""
TABLE=""
CONTNAME=""
POST=""


ARGS=`getopt -o lu:s:o:f:d:t:n:r:pha --long list,url:,stop:,logs:,name:,file:,database:,table:,post:,dump,stats,help -n 'injector' -- "$@"`

if [ $? != 0 ]; then
	exit 1
fi

usage() {
	echo "Usage: $0 -u [TARGET] [OPTIONS]"
	echo "Usage: $0 [OPTIONS]"
	echo "OPTIONS:"
	echo -e "\t-l | $GREEN--list$END$GREEN\tList all existent containers$END"
	echo -e "\t-u | $GREEN--url$END$GREEN\t Set target url to be tested (e.g. injector -u TARGET)$END"
	echo -e "\t-f | $GREEN--file$END$GREEN\t Set a file containing a list of targets (e.g. injector -f targets.txt)$END"
	echo -e "\t-d | $GREEN--database$END$GREEN\t Set the target database (e.g. injector -d <database> $END"
	echo -e "\t-t | $GREEN--table$END$GREEN\t Set the target table (e.g. injector -d <database> -t <table>)$END"
	echo -e "\t-r | $GREEN--post$END$GREEN\tSet the POST request parameters (e.g -r param1&param2 or -r POST file request)$END"
	echo -e "\t-s | $GREEN--stop$END$GREEN\tStop the specified container (e.g. injector -s <container_name>) or use -s all to stop all containers$END"
	echo -e "\t-o | $GREEN--logs$END$GREEN\tShow the container log$END"
	echo -e "\t-p | $GREEN--dump$END$GREEN\tDump the data$END"
	echo -e "\t-n | $GREEN--name$END$GREEN\tChoose a name for you sqlmap container (e.g. injector -u TARGET -n INSTANCENAME)$END"
	echo -e "\t-a | $GREEN--stats$END$GREEN\tDisplay the container's statistics$END"
	echo -e "\t-h | $GREEN--help$END$GREEN\tPrint this help$END"

	exit 0
}

stop_containers() {
	if [ $STOPCONT == "all" ]; then
		for cont in $(docker ps -aq); do
		docker stop $cont | xargs docker rm 2>/dev/null
	        rm  $INST 2>/dev/null 	
		done
	else	
		docker stop $STOPCONT | xargs docker rm 2>/dev/null
		echo -e "$GREEN $STOPCONT removed"
	fi
	exit 0
}

list_containers() {
	docker ps -a
	exit 0
}

log_containers() {
	if [ $LOGCONT = " " ]; then
		echo "Informe o nome do injector's container"
	else
		docker logs --details -f $LOGCONT
	fi
	exit 0
}

stats_containers() {
       docker stats --format "table {{.Name}} \t{{.CPUPerc}}\t{{.MemUsage}}\t{{.NetIO}}\t {{.BlockIO }} "
}

priv_kill () {
	docker stop proxy$CID 1>/dev/null
}

attack() {
    
    if [ "x"$CONTNAME == "x" ]; then
        if [ ! -f $INST ]; then
            echo -n 1 > $INST
    	else
            expr $(cat $INST) + 1 > $INST
        fi
        CID=$(cat $INST)
	    CONTNAME="injector$CID"
    fi

    echo "==> Pwning $TARGET"
    # Privoxy container
    docker run -d --rm --name proxy$CID alexoscorelabs/privoxy >> /dev/null
    sleep 2
    privoxy_ip=$(docker inspect --format '{{ .NetworkSettings.IPAddress }}' proxy$CID)
    
    if [ "x"$DATABASE == "x" ]; then
        params="--dbs"
    else
        if [ "x"$TABLE == "x" ]; then
            params="--tables -D $DATABASE"
        else
            if [ "x"$DUMP == "x" ]; then
       	        params="-T $TABLE -D $DATABASE --columns"
            else
                params="-T $TABLE -D $DATABASE --dump"
            fi
    	fi
    fi

    if [ "x"$POST != "x" ]; then
	    if [ -e $POST ]; then
        	params="--method POST -r $POST"
	    else
        	params=$params" --method POST --data $POST"
	    fi
    fi

    # Sqlmap container
    docker run -d -it -v $VOLUME --name $CONTNAME alexoscorelabs/sqlmap -u $TARGET --proxy http://$privoxy_ip:8118 $USERAGENT $params --batch $LEVEL $RISK --threads $THREADS>> /dev/null
#    sudo chown -R $USER:$USER /tmp/sqlmap
    
    # At this point docker watches the container. When it terminates, docker triggers priv_kill function in order to
    # remove privoxy container that was pairing with this sqlmap instance
    docker wait $CONTNAME 1>/dev/null && priv_kill &
    CONTNAME=""
}

read_file () {
	for NEW_TARGET in $(cat $FILE); do
        TARGET=$NEW_TARGET
        attack
	done
    exit 0
}

# Main starts here

check_service () {
echo "Checking if docker service is up..."
sudo service docker status > /dev/null

if [ $? == "3" ]; then
	echo "Starting docker..."
	sudo service docker start
	 else
        echo "Service is running...Hack the Planet"
fi
}

while true; do
  case "$1" in
    -u | --url )
	    TARGET=$2
	    shift
        shift
        if [ "x"$1 == "x" ]; then
            break
        fi
	    ;;
    -d | --database )
        DATABASE=$2
        shift
        shift
        if [ "x"$1 == "x" ]; then
            break
        fi
        ;;
    -t | --table )
        TABLE=$2
        shift
        shift
        if [ "x"$1 == "x" ]; then
            break
        fi
        ;;
    -n | --name )
        CONTNAME=$2
        shift
        shift
        if [ "x"$1 == "x" ]; then
            break
        fi
        ;;
     -r | --post )
        POST=$2
        shift
        shift
        if [ "x"$1 == "x" ]; then
            break
        fi
        ;;
    -p | --dump )
	    DUMP="True"
        shift
	    if [ "x"$1 == "x" ]; then
            break
        fi
       ;;    
    -s | --stop ) 
	    echo "Stop this: $2"
	    STOPCONT=$2
	    stop_containers
	    break
	    ;;
    -l | --list ) 
	    list_containers
	    shift
	    break
	    ;;
    -o | --logs )
	    LOGCONT=$2
	    log_containers
	    break
	    ;;
    -a | --stats )
            stats_containers
            break
	    ;;
    -f | --file )
	    FILE=$2
	    read_file
        shift
        shift
	    ;;
    -h | --help )
	    usage
	    ;;
    * ) 
	    usage
	    ;;
  esac
done

clear
check_service
attack
