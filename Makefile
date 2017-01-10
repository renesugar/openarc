DBRUNDIR?=~/run/db
DBCFGDIR?=./cfg/env/dev/db/
PYTEST_BIN?="python -m unittest discover"
PYTEST_FILE_PATTERN?="*_test.py"
PROJECT=openarc

clean:
	@rm ./${PROJECT}/*.pyc
	@rm ./${PROJECT}/tests/*.pyc
dbinit:
	-@pkill postgres
	@rm -rf /tmp/.s.PGSQL*
	@rm -rf ${DBRUNDIR}/${PROJECT}
	@/bin/mkdir -p ${DBRUNDIR}/${PROJECT}
	@pg_ctl init -D ${DBRUNDIR}/${PROJECT}
	@cp ${DBCFGDIR}/*.conf ${DBRUNDIR}/${PROJECT}
	@pg_ctl -D ${DBRUNDIR}/${PROJECT} -l /tmp/logfile start
	@sleep 10
	createdb ${PROJECT}

dbschemainit:
	@psql -d${PROJECT} < ./sql/schemacontrol.sql

dbmigrate:
	cat ./sql/${PROJECT}.*.sql | psql -d ${PROJECT}

dbrefresh: dbinit dbschemainit dbmigrate

test:
	# Todo: replace this with TAP output
	@echo "Running tests"
	@export LC_CFG_DIR=./cfg && python -m unittest discover ./${PROJECT}/tests -p ${PYTEST_FILE_PATTERN}

testclean: dbrefresh test