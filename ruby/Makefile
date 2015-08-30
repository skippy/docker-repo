NAME = skippy/ruby
VERSION = 2.2.3

all: build

build:
	docker build -t $(NAME):$(VERSION) .

test:
	docker run $(NAME):$(VERSION) ruby -e 'puts "Hello world"'

tag_latest:
	docker tag -f $(NAME):$(VERSION) $(NAME):latest

release: test tag_latest
	@if ! docker images $(NAME) | awk '{ print $$2 }' | grep -q -F $(VERSION); then echo "$(NAME) version $(VERSION) is not yet built. Please run 'make build'"; false; fi
	docker push $(NAME)


# build:
#   docker build -t skippy/ruby\:2.2.3 .

# push:
#   docker push skippy/ruby\:2.2.3
