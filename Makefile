TARGETS := agy cli config-apps easyeffects sys-monitors shell theme audio

.PHONY: all $(TARGETS) clean

all: $(TARGETS)

$(TARGETS):
	stow -v -R -t ~ $@

clean:
	stow -v -D -t ~ $(TARGETS)
