
PASSWORD=$(shell cat password || apg -n 1 -a 0 -E '";:[].,{}|=' -m 24 -x 30 | tee password)
ROOTPASSWORD=$(shell cat root_password || apg -n 1 -a 0 -E '";:[].,{}|=' -m 24 -x 30 | tee root_password)
PROXYPASSWORD=$(shell cat proxy_password || apg -n 1 -a 0 -E '";:[].,{}|=' -m 24 -x 30 | tee proxy_password)

build:
	docker build --rm -f Dockerfile.i2pd -t eyedeekay/gnusocial-i2pd .
	docker build --force-rm \
		--build-arg TOR_SOCKS_PORT=9150 \
		--build-arg TOR_SOCKS_HOST=172.82.82.3 \
		--build-arg TOR_CONTROL_PORT=9151 \
		--build-arg TOR_CONTROL_HOST=172.82.82.3 \
		-f Dockerfile.torhost -t eyedeekay/tor-host .
	docker build -f Dockerfile.mysql --build-arg PASSWORD="$(PASSWORD)" --build-arg ROOTPASSWORD="$(ROOTPASSWORD)" -t eyedeekay/gnusocial-mariadb .
	docker build -f Dockerfile.privoxy --build-arg PROXYPASSWORD="$(PROXYPASSWORD)" -t eyedeekay/gnusocial-privoxy .
	docker build -f Dockerfile -t eyedeekay/gnusocial-eepsite .


run-host: network
	docker run --restart=always -i -d -t \
		--name gnusocial-i2pd \
		--network gnusocial \
		--network-alias gnusocial-i2pd \
		--hostname gnusocial-i2pd \
		--ip 172.82.82.2 \
		-p :4567 \
		-p 127.0.0.1:7079:7079 \
		-v gnusocial:/var/lib/i2pd \
		eyedeekay/gnusocial-i2pd; true

run-torhost: network
	docker run -i -t -d \
		--name gnusocial-tor \
		--network gnusocial \
		--network-alias gnusocial-tor \
		--hostname gnusocial-tor \
		--link gnusocial-eepsite \
		--ip 172.82.82.3 \
		-v gnusocial-tor:/var/lib/tor \
		eyedeekay/tor-host; true

run-mariadb: network
	docker run -i -t -d \
		--name gnusocial-mariadb \
		--network gnusocial \
		--network-alias gnusocial-mariadb \
		--hostname gnusocial-mariadb \
		--link gnusocial-eepsite \
		--ip 172.82.82.4 \
		-v gnusocial-mysql:/var/lib/mysql \
		-v gnusocial-mysql-socket:/var/run/mysqld \
		eyedeekay/gnusocial-mariadb; true

run-privoxy: network
	docker run -i -t -d \
		--name gnusocial-privoxy \
		--network gnusocial \
		--network-alias gnusocial-privoxy \
		--hostname gnusocial-privoxy \
		--link gnusocial-eepsite \
		--ip 172.82.82.5 \
		eyedeekay/gnusocial-privoxy; true

run: build clean network run-host run-torhost run-mariadb run-privoxy
	#sleep 30s; #Wait for tor to start up.
	docker run -i -t -d \
		--name gnusocial-eepsite \
		--network gnusocial \
		--network-alias gnusocial-eepsite \
		--hostname gnusocial-eepsite \
		--link gnusocial-mariadb \
		--link gnusocial-privoxy \
		--ip 172.82.82.6 \
		-p 127.0.0.1:8080:80 \
		-v gnusocial-mysql-socket:/var/run/mysqld \
		-v gnusocial-www:/var/www/gnu-social \
		eyedeekay/gnusocial-eepsite

clean:
	docker rm -f gnusocial-eepsite gnusocial-mariadb gnusocial-privoxy; true

rinit: clean
	docker system prune -f

clobber: clean
	docker rm -f gnusocial-tor gnusocial-i2pd; true
	docker rmi -f eyedeekay/gnusocial-eepsite \
		eyedeekay/gnusocial-privoxy \
		eyedeekay/gnusocial-mariadb \
		eyedeekay/gnusocial-i2pd; true
	docker system prune -f

network:
	docker network create --subnet 172.82.82.0/24 gnusocial; true

scripts:
	@echo "SHOW DATABASES" | tee databases
	@echo "use mysql; show tables;" | tee tables
	@echo "SELECT User FROM mysql.user" | tee users
