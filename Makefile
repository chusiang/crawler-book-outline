OS_NAME := $(shell uname)

main: run_containers

# ---- Initialization ----------------------------------------------------------

init: create_venv install_packages run_containers

create_venv:
	virtualenv -p python3 .venv

install_packages:
	.venv/bin/pip3 install -r requirements.txt

run_containers:
	docker-compose up -d

# ---- Check ------------------------------------------------------------------

check: flake8_check

flake8_check:
	flake8 *.py

flake8_check_docker:
	docker run --rm -it -v $(PWD):/apps/ alpine/flake8 *.py

# ---- Parser ------------------------------------------------------------------

# make telong <ISBN-13>
#
# https://stackoverflow.com/a/6273809/686105

telong:
	. .venv/bin/activate && python3 tenlong.py	$(filter-out $@,$(MAKECMDGOALS))

books:
	. .venv/bin/activate && python3 books.py		$(filter-out $@,$(MAKECMDGOALS))

%:
	@:

# ---- Run ---------------------------------------------------------------------

run: review_serve

review_html:
ifeq (${OS_NAME}, Darwin)
	open index.html
else
	firefox index.html
endif

review_serve:
ifeq (${OS_NAME}, Darwin)
	open http://localhost
else
	firefox http://localhost
endif

# ---- Clean -------------------------------------------------------------------

remove_virtualenv:
	-rm -rf .venv

remove_containers:
	docker-compose down -v

clean: remove_virtualenv remove_containers
	-rm -f *.html
