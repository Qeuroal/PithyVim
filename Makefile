.PHONY: l local \
	r restore \
	gm gitmerge

l local:
	@cp -rf ./lua ~/.local/share/nvim/lazy/PithyVim/

GITMERGE_INFO=merge dev
gm gitmerge:
	@echo ">>> GITMERGE_INFO: ${GITMERGE_INFO}."
	@git switch master && git merge --no-ff -m "${GITMERGE_INFO}" dev && git push && git switch dev

