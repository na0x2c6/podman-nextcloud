MKDIR = mkdir
CP = cp
RM = rm
SYSTEMCTL = systemctl --user


service = nextcloud.service

systemd-units-path = $(HOME)/.config/systemd/user
quadlet-units-path = $(HOME)/.config/containers/systemd

systemd-units-installed = $(addprefix $(systemd-units-path)/,$(notdir $(wildcard systemd-units/*)))
quadlet-installed = $(addprefix $(quadlet-units-path)/,$(notdir $(wildcard quadlet/*)))

timer-enabled = $(addprefix $(systemd-units-path)/timers.target.wants/, $(notdir $(wildcard systemd-units/*.timer)))


# TODO dynamic replacing
# K8S_YAML_PATH ?= $(patsubst $(HOME)/%,\%h/%,$(realpath $(wildcard nextcloud.yaml))
# PUBLISH_PORT ?= 8080

install:

-include custom.mk

.PHONY: install start stop clean
install: $(systemd-units-installed) $(quadlet-installed) $(timer-enabled)

start stop:
	$(SYSTEMCTL) $@ $(service)

$(systemd-units-path)/%: systemd-units/%
	$(MKDIR) -p $(dir $@)
	$(CP) -f $^ $@
	$(SYSTEMCTL) daemon-reload

$(quadlet-units-path)/%: quadlet/%
	$(MKDIR) -p $(dir $@)
	$(CP) -f $^ $@
	$(SYSTEMCTL) daemon-reload

$(systemd-units-path)/timers.target.wants/%.timer: $(systemd-units-path)/%.timer $(systemd-units-path)/%.service
	$(SYSTEMCTL) enable $*.timer

clean:
	$(SYSTEMCTL) disable $(notdir $(timer-enabled))
	$(RM) $(systemd-units-installed) $(quadlet-installed)
