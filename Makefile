
PASSWORD=$(shell cat password || apg -n 1 -a 0 -E '";:[].,{}|=' -m 24 -x 30 | tee password)

build:
	docker build --rm -f Dockerfile.i2pd -t eyedeekay/gnusocial-i2pd .
	docker build -f Dockerfile -t eyedeekay/gnusocial-eepsite .
	docker build -f Dockerfile.mysql --build-arg PASSWORD="$(PASSWORD)" -t eyedeekay/gnusocial-mariadb .
	docker build --force-rm \
		--build-arg TOR_SOCKS_PORT=9150 \
		--build-arg TOR_SOCKS_HOST=172.82.82.4 \
		--build-arg TOR_CONTROL_PORT=9151 \
		--build-arg TOR_CONTROL_HOST=172.82.82.4 \
		-f Dockerfile.torhost -t eyedeekay/tor-host .

run-host: network
	docker run --restart=always -i -d -t \
		--name gnusocial-i2pd \
		--network gnusocial \
		--network-alias gnusocial-i2pd \
		--hostname gnusocial-i2pd \
		--ip 172.82.82.2 \
		-p :4567 \
		-p 127.0.0.1:7070:7070 \
		-v eepsite:/var/lib/i2pd \
		eyedeekay/gnusocial-i2pd; true

mariadb-run: network
	docker run -i -t -d \
		--name gnusocial-mariadb \
		--network gnusocial \
		--network-alias gnusocial-mariadb \
		--hostname gnusocial-mariadb \
		--link gnusocial-eepsite \
		--ip 172.82.82.3 \
		-v mysql:/var/lib/mysql \
		-v mysql-socket:/var/run/mysqld \
		eyedeekay/gnusocial-mariadb; true

run-torhost: network
	docker run -i -t -d \
		--name gnusocial-tor \
		--network gnusocial \
		--network-alias gnusocial-tor \
		--hostname gnusocial-tor \
		--link gnusocial-eepsite \
		--expose 9150 \
		--ip 172.82.82.4 \
		-v gnusocial-tor:/var/lib/tor \
		eyedeekay/tor-host; true

run: build clean network run-host mariadb-run run-torhost
	sleep 30s; #Wait for tor to start up.
	docker run -i -t -d \
		--name gnusocial-eepsite \
		--network gnusocial \
		--network-alias gnusocial-eepsite \
		--hostname gnusocial-eepsite \
		--link gnusocial-mariadb \
		--ip 172.82.82.5 \
		-p 127.0.0.1:8080:80 \
		-v mysql-socket:/var/run/mysqld \
		eyedeekay/gnusocial-eepsite

clean:
	docker rm -f gnusocial-eepsite gnusocial-mariadb;true

network:
	docker network create --subnet 172.82.82.0/24 gnusocial; true
