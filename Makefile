.PHONY: l local \
	r restore \
	gm gitmerge

GITMERGE_INFO=merge dev

l local:
	@cp -rf ./lua ~/.local/share/nvim/lazy/PithyVim/


gm gitmerge:
	git switch master && git merge --no-ff -m "${GITMERGE_INFO}" dev && git push && git switch dev


