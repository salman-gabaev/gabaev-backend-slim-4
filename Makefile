#Start_________________________________________________________________________________________________________________
first-start:
	make idea
	make install
	make up

#Docker_________________________________________________________________________________________________________________
up:
	docker network create bqgid || true
	make docker-compose COMMAND="up -d"

down:
	make docker-compose COMMAND="down"

start:
	make docker-compose COMMAND="start"

stop:
	make docker-compose COMMAND="stop"

docker-compose:
	docker-compose -f ./infra/local/docker-compose.yml --env-file infra/local/.env --project-name project-gabaev-template-backend-slim-4 ${COMMAND}


#Composer_______________________________________________________________________________________________________________
install:
	make run-on-docker-image COMMAND="./composer.phar install"

update:
	make run-on-docker-image COMMAND="./composer.phar update"

require:
	make run-on-docker-image COMMAND="./composer.phar require ${name}"

#Checkers_______________________________________________________________________________________________________________
check:
	make static-analyse && make cs-check && make unit-test && make mutation-test && echo "\n\033[0;32m SUCCESS"

static-analyse:
	make run-on-docker-image COMMAND="config/phpstan.phar --memory-limit=-1 --configuration='config/phpstan.neon.dist'"

cs-check:
	make run-on-docker-image COMMAND="vendor/bin/php-cs-fixer fix -vvv --dry-run --show-progress=dots --config=./config/.php-cs-fixer.dist --allow-risky=yes"

cs-fix:
	make run-on-docker-image COMMAND="vendor/bin/php-cs-fixer fix -vvv --show-progress=dots --config=./config/.php-cs-fixer.dist --allow-risky=yes"

check-coverage:
	make run-on-docker-image COMMAND="php test/check-coverage.php"

unit-test:
	make run-on-docker-image COMMAND="phpunit -c /app/test/phpunit.xml --strict-coverage" && make check-coverage

mutation-test:
	make run-on-docker-image COMMAND="php vendor/infection/infection/bin/infection --threads=4 -v -s --debug --configuration=config/infection.json.dist"

#Ide____________________________________________________________________________________________________________________
idea:
	cp -r config/ide/idea/* .idea

idea-update:
	#Use to update dist ide in config
	cp -r .idea/codeStyles config/ide/idea/codeStyles
	cp -r .idea/inspectionProfiles config/ide/idea/inspectionProfiles
	cp -r .idea/misc.xml config/ide/idea/misc.xml
	cp -r .idea/php-docker-settings.xml config/ide/idea/php-docker-settings.xml
	cp -r .idea/php-test-framework.xml config/ide/idea/php-test-framework.xml
	cp -r .idea/remote-mappings.xml config/ide/idea/remote-mappings.xml
	cp -r .idea/externalDependencies.xml config/ide/idea/externalDependencies.xml
	cp -r .idea/phpunit.xml config/ide/idea/phpunit.xml
	cp -r .idea/php.xml config/ide/idea/php.xml

#Git____________________________________________________________________________________________________________________
setup-hooks:
	cp -r ./config/hooks .git/ && chmod -R +x .git/hooks/

pre-commit-hook:
	echo "STATIC ANALYZE..." && make static-analyse > /dev/null 2>&1\
	&& echo "CODE STYLE CHECK..." && make cs-check > /dev/null 2>&1\
	&& echo "UNIT TEST..." && make unit-test > /dev/null 2>&1\
	&& echo "MUTATION TEST..." && make mutation-test > /dev/null 2>&1\

post-commit-hook:
	echo "DONE"

#System_________________________________________________________________________________________________________________
run-on-docker-image:
	docker run --rm --env XDEBUG_MODE=coverage -v "${PWD}"/:/app project-gabaev-template-backend-slim-4_app ${COMMAND}
