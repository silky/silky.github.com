.PHONY: site

json:
	# Make books.json
	npx -- m2j -w 0 books/*.md >js/books.json

site: json
	stack run -- -- clean && stack run -- -- watch
