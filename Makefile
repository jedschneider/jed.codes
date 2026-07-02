.PHONY: build serve preview clean

build:
	hugo --minify
	npx -y pagefind --site public

serve:
	hugo server -D

preview: build
	python3 -m http.server 8000 --directory public

clean:
	rm -rf public resources
