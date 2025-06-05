.INTERMEDIATE: pack pack-base

pack: pack-base


# Create listing of all potention installed files
.INTERMEDIATE: $(ISO_TARGET)/.aaa_base.found
$(ISO_TARGET)/.aaa_base.found: stage2
	@echo pack-find
	@find $(ISO_TARGET) ! -path '$(ISO_TARGET)/.*' -a \
	! -path '$(ISO_TARGET)/etc/machine-id' -a \
	! -path '$(ISO_TARGET)/etc/ssh/ssh_host_*' -a \
	! -path '$(ISO_TARGET)/etc/dracut.conf.d/02-lunar-live.conf' \
	-printf '/%P\n' \( \
	-path '$(ISO_TARGET)/dev' -o \
	-path '$(ISO_TARGET)/etc/lunar/local' -o \
	-path '$(ISO_TARGET)/mnt' -o \
	-path '$(ISO_TARGET)/proc' -o \
	-path '$(ISO_TARGET)/root' -o \
	-path '$(ISO_TARGET)/sys' -o \
	-path '$(ISO_TARGET)/tmp' -o \
	-path '$(ISO_TARGET)/boot' -o \
	-path '$(ISO_TARGET)/lib/modules' -o \
	-path '$(ISO_TARGET)/usr/include' -o \
	-path '$(ISO_TARGET)/usr/lib' -o \
	-path '$(ISO_TARGET)/usr/libexec' -o \
	-path '$(ISO_TARGET)/usr/share' -o \
	-path '$(ISO_TARGET)/usr/src' -o \
	-path '$(ISO_TARGET)/var/cache' -o \
	-path '$(ISO_TARGET)/var/lib/lunar' -o \
	-path '$(ISO_TARGET)/var/log' -o \
	-path '$(ISO_TARGET)/var/spool' -o \
	-path '$(ISO_TARGET)/var/state/lunar' \) -prune > $@

# Create listing of all installed files
.INTERMEDIATE: $(ISO_TARGET)/.aaa_base.tracked
$(ISO_TARGET)/.aaa_base.tracked: stage2
	@echo pack-tracked
	@sort -u $(ISO_TARGET)/var/log/lunar/install/* > $@

# Filter listing of all installed files
.INTERMEDIATE: $(ISO_TARGET)/.aaa_base.filtered
$(ISO_TARGET)/.aaa_base.filtered: $(ISO_TARGET)/.aaa_base.found $(ISO_TARGET)/.aaa_base.tracked
	@echo pack-filtered
	@sort $^ | uniq -d > $@

# Diff listing of files
.INTERMEDIATE: $(ISO_TARGET)/.aaa_base.list
$(ISO_TARGET)/.aaa_base.list: $(ISO_TARGET)/.aaa_base.found $(ISO_TARGET)/.aaa_base.filtered
	@echo pack-list
	@sort $^ | uniq -u | sed 's:^/::' > $@

# Create tar with not tracked files
$(ISO_TARGET)/var/cache/lunar/aaa_base.tar.xz: $(ISO_TARGET)/.aaa_base.list
	@echo pack-base
	@tar -cf $@ -C $(ISO_TARGET) --no-recursion -T $<

pack-base: $(ISO_TARGET)/var/cache/lunar/aaa_base.tar.xz
