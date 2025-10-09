.PHONY: l local \
	r restore \
	gm gitmerge

l local:
	@cp -rf ./lua ~/.local/share/nvim/lazy/PithyVim/

GITMERGE_INFO ?=
gm gitmerge:
ifdef GITMERGE_INFO
	@echo "\033[32m>>> GITMERGE_INFO: ${GITMERGE_INFO}\033[0m"
	@git switch master && git merge --no-ff -m "merge dev (${GITMERGE_INFO})" dev && git push && git switch dev
else
	@git switch master && git merge --no-ff -m "merge dev" dev && git push && git switch dev
endif

