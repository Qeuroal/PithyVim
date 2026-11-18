.PHONY: l local \
	gm gitmerge \
	t test

l local:
	@cp -rf ./lua ~/.local/share/nvim/lazy/PithyVim/

t test:
	@bash scripts/test

GITMERGE_INFO ?=
MERGE_MSG = merge dev$(if $(GITMERGE_INFO), ($(GITMERGE_INFO)))
MASTER_WT = $(shell git worktree list --porcelain | awk '/^worktree / {p=substr($$0,10)} /^branch refs\/heads\/master$$/ {print p; exit}')
gm gitmerge:
ifneq ($(MASTER_WT),)
	@git -C "$(MASTER_WT)" merge --no-ff -m "$(MERGE_MSG)" dev
	@git -C "$(MASTER_WT)" push
else
	@git switch master && git merge --no-ff -m "$(MERGE_MSG)" dev && git push && git switch dev
endif
