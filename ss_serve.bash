#!/bin/bash

# This traps the CTRL+C command to kill the script, and kills all the
# background processes that it started.
trap handler SIGINT
handler()
{
    echo "kill -9 $PID1"
    kill -9 $PID1
    echo "kill -9 $PID2"
    kill -9 $PID2
    echo "kill -9 $PID3"
    kill -9 $PID3
    echo "kill -9 $PID4"
    kill -9 $PID4
}

# Colors
C_YEL='\033[1;33m'
C_NRM='\033[0m' # No Color


# Use -gt 1 to consume two arguments per pass in the loop (e.g. each
# argument has a corresponding value to go with it).
# Use -gt 0 to consume one or more arguments per pass in the loop (e.g.
# some arguments don't have a corresponding value to go with it such
# as in the --default example).
# note: if this is set to -gt 0 the /etc/hosts part is not recognized ( may be a bug )
while [[ $# -gt 0 ]] ; do
    key="$1"

    case $key in
	-b|--build)
	    SS_BUILD=true
	    ;;
	*)
            # unknown option
	    echo "USAGE:  ss_serve.bash [-b|--build]"
	    echo
	    echo "  The --build option will run 'mvn package' on all the"
	    echo "  different services. It won't run them by default."
	    echo
	    echo "  Current Services:"
	    echo "    - smartsync-config-service"
	    echo "    - smartsync-eureka-service"
	    echo "    - smartsync-hystrix-dashboard"
	    echo "    - smartsync-zipkin-service"
	    exit
	    ;;
    esac
    shift # past argument or value
done

echo -e "${C_YEL}Starting SmartSync services..."
echo -e "    smartsync-config-services:    8888"
echo -e "    smartsync-eureka-services:    8761"
echo -e "    smartsync-hystrix-dashboard:  8010"
echo -e "    smartsync-zipkin-service:     9411${C_NRM}"
sleep 2

# Run maven package on services
if [ "$SS_BUILD" = true ] ; then
    echo -e "${C_YEL}Running Maven packages...${C_NRM}"
    echo -e "${C_YEL}cd smartsync-config-service; mvn package${C_NRM}"
    cd smartsync-config-service
    mvn package
    echo -e "${C_YEL}cd smartsync-eureka-service; mvn package${C_NRM}"
    cd ../smartsync-eureka-service
    mvn package
    echo -e "${C_YEL}cd smartsync-hystrix-dashboard; mvn package${C_NRM}"
    cd ../smartsync-hystrix-dashboard
    mvn package
    echo -e "${C_YEL}cd smartsync-zipkin-service; mvn package${C_NRM}"
    cd ../smartsync-zipkin-service
    mvn package
    cd ..
fi

echo -e "${C_YEL}java -jar smartsync-config-service/target/config-service-0.0.1-SNAPSHOT.jar${C_NRM}"
java -jar smartsync-config-service/target/smartsync-config-service-0.0.1-SNAPSHOT.jar &
PID1=$!
echo $PID1
sleep 10

echo -e "${C_YEL}java -jar smartsync-eureka-service/target/eureka-service-0.0.1-SNAPSHOT.jar${C_NRM}"
java -jar smartsync-eureka-service/target/smartsync-eureka-service-0.0.1-SNAPSHOT.jar &
PID2=$!
echo $PID2
sleep 10

echo -e "${C_YEL}java -jar smartsync-hystrix-dashboard/target/hystrix-dashboard-0.0.1-SNAPSHOT.jar${C_NRM}"
java -jar smartsync-hystrix-dashboard/target/smartsync-hystrix-dashboard-0.0.1-SNAPSHOT.jar &
PID3=$!
echo $PID3

echo -e "${C_YEL}java -jar smartsync-zipkin-service/target/zipkin-service-0.0.1-SNAPSHOT.jar${C_NRM}"
java -jar smartsync-zipkin-service/target/smartsync-zipkin-service-0.0.1-SNAPSHOT.jar &
PID4=$!
echo $PID4

wait
