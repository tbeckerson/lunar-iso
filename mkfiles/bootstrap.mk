.INTERMEDIATE: target bootstrap bootstrap-base bootstrap-lunar

.SECONDARY: $(ISO_TARGET)/.target $(ISO_TARGET)/.base $(ISO_TARGET)/.modules $(ISO_SOURCE)/cache/.copied

bootstrap: bootstrap-base bootstrap-lunar


# this rule is shared with the download
$(ISO_TARGET)/.target:
	@rm -rf $(ISO_TARGET)
	@mkdir -p $(ISO_TARGET)
	@touch $@

target: $(ISO_TARGET)/.target


# fill the target with the base file required
$(ISO_TARGET)/.base: target
	@echo bootstrap-base
	@mkdir -p $(ISO_TARGET)/{dev,proc,run,sys,tmp,usr/{bin,lib},var}
	@ln -sf usr/bin $(ISO_TARGET)/bin
	@ln -sf usr/bin $(ISO_TARGET)/sbin
	@ln -sf bin $(ISO_TARGET)/usr/sbin
	@ln -sf usr/lib $(ISO_TARGET)/lib
	@ln -sf usr/lib $(ISO_TARGET)/lib64
	@ln -sf lib $(ISO_TARGET)/usr/lib64
	@ln -sf ../run/lock $(ISO_TARGET)/var/lock
	@ln -sf ../run $(ISO_TARGET)/var/run
	@cp -r $(ISO_SOURCE)/template/etc $(ISO_TARGET)
	@echo MAKES=$(ISO_MAKES) > $(ISO_TARGET)/etc/lunar/local/optimizations.GNU_MAKE
	@touch $@

bootstrap-base: $(ISO_TARGET)/.base


# bootstrap on a lunar host
$(ISO_SOURCE)/cache/.copied:
	@echo bootstrap-lunar-cache
	@$(ISO_SOURCE)/scripts/bootstrap-lunar-cache
	@touch $@

# note: use cat after grep to ignore the exit code of grep
$(ISO_TARGET)/.modules: $(ISO_SOURCE)/cache/.copied
	@echo bootstrap-lunar
	@mkdir -pv $(ISO_TARGET)
	@for archive in $(ISO_SOURCE)/cache/*-$(ISO_BUILD).tar.xz ; do \
	  mkdir -pv /tmp/"$$archive" || exit 1 ; \
	  tar -xf "$$archive" -C /tmp/"$$archive" || exit 1 ; \
	  rsync -a --keep-dirlinks /tmp/"$$archive"/* $(ISO_TARGET) || exit 1 ; \
	  rm -rf /tmp/"$$archive" || exit 1 ; \
	done
	@mkdir -p $(ISO_TARGET)/var/state/lunar
	@touch $(ISO_TARGET)/var/state/lunar/packages.backup
	@grep -v "`sed 's/^/^/;s/:.*/:/' $(ISO_SOURCE)/cache/packages`" $(ISO_TARGET)/var/state/lunar/packages.backup | cat > $(ISO_TARGET)/var/state/lunar/packages
	@cat $(ISO_SOURCE)/cache/packages >> $(ISO_TARGET)/var/state/lunar/packages
	@cp $(ISO_TARGET)/var/state/lunar/packages $(ISO_TARGET)/var/state/lunar/packages.backup
	@touch $@

bootstrap-lunar: $(ISO_TARGET)/.modules
