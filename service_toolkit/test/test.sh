#!/bin/bash
#TODOS: 
#  * need to know the hidden details to test (such as where the keys are stored in etcdctl).  bad!
#  * the setup is brittle

# set -eo pipefail
# set -eo errexit
# set -x
# vagrant ssh service-toolkit-test -- -A



COREOS_IP=172.17.8.200 #defined in Vagrantfile

echo 'starting vagrant test env'
    # make sure we start with a clean slate
	vagrant destroy -f > /dev/null 2>&1
	output=`vagrant up`
	port=`echo $output | grep -Eo 'service-toolkit-test: 2375 => (\d+)' | awk '{print $4}'`
	# port=2375	
	docker="docker -H 127.0.0.1:$port"
	docker_run="$docker run --rm --name test-service-toolkit "
	sleep 10 #it takes coreos a few seconds to make sure docker is up and running

echo 'building skippy/service_toolkit within test env'
	$docker build -q -t skippy/service_toolkit ../. > /dev/null 2>&1


function expect_success() { 
	ret=$?
	if [ "$ret" -ne "0" ]; then
		printf '\033[31mFail\033[m\n'
		if [ "$1" != "" ]; then
			printf "   at label: $1\n"
		fi
		printf "\n\n"
	    exit $ret
	else
		printf '\033[32m.\033[m'	
    fi
}

function print_success() {
	printf '\033[32m Pass\033[m\n'	
}

function reset_locks() {
	vagrant ssh service-toolkit-test -- -A 'etcdctl rm --recursive /locks' > /dev/null 2>&1
}

function reset_services() {
	vagrant ssh service-toolkit-test -- -A 'etcdctl rm --recursive /services' > /dev/null 2>&1	
}

function test_group_title() {
	echo -e "\n------------------ Checking: $1"
}

function test_title() {
	echo -n "   - $1: "
}


function expect_text() {
	echo $1 | grep -iE "$2" > /dev/null 2>&1
	expect_success "checking for '$2' amongst $1"
}


function expect() {
	test "$1" $2 "$3"
	expect_success "'$1' $2 '$3'"
}


test_group_title 'acquire-lease'
	#start clean!
	reset_locks

test_title 'attempt to acquire lease'
	output=`$docker_run skippy/service_toolkit acquire-lease --label=MyService --service-id=MyService-1 --host-ip=$COREOS_IP`
	expect_success "check1"
	expect_text "$output", 'acquired lease'
	output=`vagrant ssh service-toolkit-test -- -A 'etcdctl get /locks/myservice'`
	expect "$output" = "MyService-1"
	reset_locks
	print_success

test_title 'lease has a ttl'
	$docker_run skippy/service_toolkit acquire-lease --label=MyService --service-id=MyService-1 --host-ip=$COREOS_IP > /dev/null 2>&1
	expect_success "check1"
	output=`vagrant ssh service-toolkit-test -- -A 'curl -sL http://127.0.0.1:4001/v2/keys/locks/myservice'`
	expect_success "check2"
	ttl=`echo $output | grep -Eo '"ttl":\d+' | awk -F ':' '{print $2}'`
	expect_success "check3"
	test $ttl -gt 200
	expect_success "check4"
	reset_locks
	print_success

test_title 'cannot grab a lease until the old one expires'
	t1=`date +"%s"`
	$docker_run skippy/service_toolkit acquire-lease --label=MyService --service-id=MyService-1 --host-ip=$COREOS_IP --lease-timeout=5 > /dev/null 2>&1
	output=`$docker_run skippy/service_toolkit acquire-lease --label=MyService --service-id=MyService-2 --host-ip=$COREOS_IP`
	expect_success "check1"
	t2=`date +"%s"`
	expect_text "$output", 'acquired lease'
	output=`vagrant ssh service-toolkit-test -- -A 'etcdctl get /locks/myservice'`
	expect_success "check3"
	expect "$output" = "MyService-2"
	test $(expr $t2 - $t1) -ge 5
	expect_success "check5"
	test $(expr $t2 - $t1) -le 10
	expect_success "check6"
	reset_locks
	print_success

test_title 'acquire lease for a different service label when another lease is outstanding'
	output=`$docker_run skippy/service_toolkit acquire-lease --label=MyService --service-id=MyService-1 --host-ip=$COREOS_IP`
	expect_success "check1"
	expect_text "$output", 'acquired lease'
	t1=`date +"%s"`
	output=`$docker_run skippy/service_toolkit acquire-lease --label=MyService-other --service-id=MyService-1 --host-ip=$COREOS_IP`
	expect_success "check2"
	expect_text "$output", 'acquired lease'
	t2=`date +"%s"`
	output=`vagrant ssh service-toolkit-test -- -A 'etcdctl get /locks/myservice-other'`
	expect_success "check3"
	expect "$output" = "MyService-1"
	#make sure we didn't wait for a long time!
	test $(expr $t2 - $t1) -le 5
	expect_success "check5"
	reset_locks
	print_success

test_title 'acquire the same lease when the same service label and ID are asking for it'
	output=`$docker_run skippy/service_toolkit acquire-lease --label=MyService --service-id=MyService-1 --host-ip=$COREOS_IP`
	expect_success "check1"
	expect_text "$output", 'acquired lease'
	t1=`date +"%s"`
	output=`$docker_run skippy/service_toolkit acquire-lease --label=MyService --service-id=MyService-1 --host-ip=$COREOS_IP`
	expect_success "check2"
	expect_text "$output", 'acquired lease'
	t2=`date +"%s"`
	output=`vagrant ssh service-toolkit-test -- -A 'etcdctl get /locks/myservice'`
	expect_success "check3"
	expect "$output" = "MyService-1"
	#make sure we didn't wait for a long time!
	test $(expr $t2 - $t1) -le 5
	expect_success "check5"
	reset_locks
	print_success




test_group_title 'hosts'
	#start clean!
	reset_services

test_title 'returns an empty string when no hosts are present'
	output=`$docker_run skippy/service_toolkit hosts --label=MyService --host-ip=$COREOS_IP`
	expect_success "check1"
	expect "$output" = ""
	reset_services
	print_success

test_title 'returns a single host when one host is registered'
	vagrant ssh service-toolkit-test -- -A 'etcdctl set /services/myservice/hosts/10.0.0.1 junk' > /dev/null 2>&1
	output=`$docker_run skippy/service_toolkit hosts --label=MyService --host-ip=$COREOS_IP`
	expect_success "check1"
	expect "$output" = '10.0.0.1'
	reset_services
	print_success

test_title 'returns a comma delimited list when multiple hosts exist'
	vagrant ssh service-toolkit-test -- -A 'etcdctl set /services/myservice/hosts/10.0.0.1 junk' > /dev/null 2>&1
	vagrant ssh service-toolkit-test -- -A 'etcdctl set /services/myservice/hosts/10.0.0.2 junk' > /dev/null 2>&1
	vagrant ssh service-toolkit-test -- -A 'etcdctl set /services/myservice/hosts/10.0.0.10 junk' > /dev/null 2>&1
	output=`$docker_run skippy/service_toolkit hosts --label=MyService --host-ip=$COREOS_IP`
	expect_success "check1"
	expect "$output" = '10.0.0.1,10.0.0.10,10.0.0.2'
	reset_services
	print_success

test_title 'returns a comma delimited list only from the service specified'
	vagrant ssh service-toolkit-test -- -A 'etcdctl set /services/myservice/hosts/10.0.0.1 junk' > /dev/null 2>&1
	vagrant ssh service-toolkit-test -- -A 'etcdctl set /services/myservice-other/hosts/10.0.0.10 junk' > /dev/null 2>&1
	vagrant ssh service-toolkit-test -- -A 'etcdctl set /services/myservice/hosts/10.0.0.2 junk' > /dev/null 2>&1
	vagrant ssh service-toolkit-test -- -A 'etcdctl set /services/myservice-other/hosts/10.0.0.2 junk' > /dev/null 2>&1
	vagrant ssh service-toolkit-test -- -A 'etcdctl set /services/myservice/hosts/10.0.0.5 junk' > /dev/null 2>&1
	output=`$docker_run skippy/service_toolkit hosts --label=MyService --host-ip=$COREOS_IP`
	expect_success "check1"
	expect "$output" = '10.0.0.1,10.0.0.2,10.0.0.5'
	reset_services
	print_success




test_group_title 'watch'
	#start clean!
	reset_services

function clean_watch_shutdown() {
	$docker stop nginx > /dev/null 2>&1
	$docker rm nginx > /dev/null 2>&1
	$docker stop toolkit > /dev/null 2>&1
	$docker rm toolkit > /dev/null 2>&1
}


test_title 'adds a host if the monitor-url is successful'
	clean_watch_shutdown
	output=`$docker_run skippy/service_toolkit hosts --label=webServ --host-ip=$COREOS_IP`
	expect_success "check1"
	expect "$output" = ''
	$docker run -d --name=nginx -p 8080:80 nginx > /dev/null 2>&1
	$docker run -d --name=toolkit skippy/service_toolkit watch --label=webServ --host-ip=$COREOS_IP --monitor-url=http://172.17.8.200:8080 > /dev/null 2>&1
	output=`$docker_run skippy/service_toolkit hosts --label=webServ --host-ip=$COREOS_IP`
	expect_success "check2"
	expect "$output" = '172.17.8.200'
	clean_watch_shutdown
	reset_services
	print_success


test_title 'does not add a host if the monitor-url is not successful'
	clean_watch_shutdown
	$docker run -d --name=toolkit skippy/service_toolkit watch --label=webServ --host-ip=$COREOS_IP --monitor-url=http://172.17.8.200:8000 > /dev/null 2>&1
	output=`$docker_run skippy/service_toolkit hosts --label=webServ --host-ip=$COREOS_IP`
	expect_success "check1"
	expect "$output" = ''
	sleep 9
	output=`$docker_run skippy/service_toolkit hosts --label=webServ --host-ip=$COREOS_IP`
	expect_success "check2"
	expect "$output" = ''
	clean_watch_shutdown
	reset_services
	print_success

test_title 'removes the host if the monitor-url was successful and then is not'
	clean_watch_shutdown
	$docker run -d --name=nginx -p 8080:80 nginx > /dev/null 2>&1
	$docker run -d --name=toolkit skippy/service_toolkit watch --label=webServ --host-ip=$COREOS_IP --monitor-url=http://172.17.8.200:8080 > /dev/null 2>&1
	output=`$docker_run skippy/service_toolkit hosts --label=webServ --host-ip=$COREOS_IP`
	expect_success "check1"
	expect "$output" = '172.17.8.200'
	$docker kill nginx > /dev/null 2>&1
	output=`$docker_run skippy/service_toolkit hosts --label=webServ --host-ip=$COREOS_IP`
	expect_success "check2"
	expect "$output" = '172.17.8.200'
	sleep 9
	output=`$docker_run skippy/service_toolkit hosts --label=webServ --host-ip=$COREOS_IP`
	expect_success "check3"
	expect "$output" = ''
	clean_watch_shutdown
	reset_services
	print_success

test_title 'if the monitoring instance suddenly dies, the IP address will eventually be removed'
	clean_watch_shutdown
	$docker run -d --name=nginx -p 8080:80 nginx > /dev/null 2>&1
	$docker run -d --name=toolkit skippy/service_toolkit watch --label=webServ --host-ip=$COREOS_IP --monitor-url=http://172.17.8.200:8080 > /dev/null 2>&1
	output=`$docker_run skippy/service_toolkit hosts --label=webServ --host-ip=$COREOS_IP`
	expect_success "check1"
	expect "$output" = '172.17.8.200'
	#lets kill, so it shutdowns without time to cleanup after itself
	$docker kill toolkit > /dev/null 2>&1
	output=`$docker_run skippy/service_toolkit hosts --label=webServ --host-ip=$COREOS_IP`
	expect_success "check2"
	expect "$output" = '172.17.8.200'
	sleep 12
	output=`$docker_run skippy/service_toolkit hosts --label=webServ --host-ip=$COREOS_IP`
	expect_success "check3"
	expect "$output" = ''
	clean_watch_shutdown
	reset_services
	print_success

test_title 'adds a default package of information to etcd if the monitor-url is successful'
	clean_watch_shutdown
	$docker run -d --name=nginx -p 8080:80 nginx > /dev/null 2>&1
	$docker run -d --name=toolkit skippy/service_toolkit watch --label=webServ --host-ip=$COREOS_IP --monitor-url=http://172.17.8.200:8080 > /dev/null 2>&1

	output=`vagrant ssh service-toolkit-test -- -A 'etcdctl get /services/webserv/hosts/172.17.8.200'`
	expect_text "$output", '{"ip": ".+?", "host": ".+?", "label": ".+?"}'
	expect_text "$output", '"ip": "172.17.8.200"'
	expect_text "$output", '"label": "webserv"'
	clean_watch_shutdown
	reset_services
	print_success



printf '\n\033[32m Success! \033[m\n\n'
# CLEANUP!
vagrant destroy -f > /dev/null 2>&1
