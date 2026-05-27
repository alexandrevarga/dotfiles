TARGETS := agy cli config-apps easyeffects monitor shell theme

.PHONY: all $(TARGETS) clean

all: $(TARGETS)

$(TARGETS):
	stow -v -R -t ~ $@

clean:
	stow -v -D -t ~ $(TARGETS)
