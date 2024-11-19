.PHONY: l local \
	r restore \
	gm gitmerge


l local:
	@cp -rf ./lua ~/.local/share/nvim/lazy/PithyVim/


gm gitmerge:
	@git switch master && git merge --no-ff -m "merge dev" dev && git push && git switch dev


