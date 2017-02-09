progsdir=$(libexecdir)/gnt-networking
commondir=$(datadir)/gnt-networking
fermdir=$(sysconfdir)/ferm
ganetidir=$(sysconfdir)/ganeti
hooksdir=$(ganetidir)/hooks
xendir=$(sysconfdir)/xen/scripts
networkdir=$(sysconfdir)/network


dist_progs_SCRIPTS = $(srcdir)/mac2eui64 $(srcdir)/runlocked \
		     $(srcdir)/prv-net-helper $(srcdir)/vmrouter.ifup \
		     $(srcdir)/vmrouter.ifdown $(srcdir)/gnt-networking-log \
		     $(srcdir)/gnt-networking-hook \
		     $(srcdir)/gnt-networking-dnshook

dist_common_DATA = $(srcdir)/common.sh


dist_ferm_DATA = $(srcdir)/gnt-networking.ferm

dist_ganeti_SCRIPTS = $(srcdir)/kvm-ifup-custom $(srcdir)/kvm-ifdown-custom \
		      $(srcdir)/ifup-extra

dist_xen_SCRIPTS = $(srcdir)/vif-custom

edit = $(SED) \
       -e 's|@sysconfdir[@]|$(sysconfdir)|g' \
       -e 's|@localstatedir[@]|$(localstatedir)|g' \
       -e 's|@libexecdir[@]|$(libexecdir)|g' \
       -e 's|@datadir[@]|$(datadir)|g'

%:%.in Makefile
	rm -f $@ $@.tmp
	srcdir=''; \
		test -f ./$@.in || srcdir=$(srcdir)/; \
		$(edit) $${srcdir}$@.in >$@.tmp
	mv $@.tmp $@

install-exec-hook:
	$(MKDIR_P) $(DESTDIR)$(hooksdir)/instance-remove-post.d
	$(LN_S) $(progsdir)/gnt-networking-hook $(DESTDIR)$(hooksdir)/instance-remove-post.d/gnt-networking-hook
	$(MKDIR_P) $(DESTDIR)$(hooksdir)/instance-stop-post.d
	$(LN_S) $(progsdir)/gnt-networking-hook $(DESTDIR)$(hooksdir)/instance-stop-post.d/gnt-networking-hook
	$(MKDIR_P) $(DESTDIR)$(hooksdir)/instance-migrate-post.d
	$(LN_S) $(progsdir)/gnt-networking-hook $(DESTDIR)$(hooksdir)/instance-migrate-post.d/gnt-networking-hook
	$(MKDIR_P) $(DESTDIR)$(hooksdir)/instance-failover-post.d
	$(LN_S) $(progsdir)/gnt-networking-hook $(DESTDIR)$(hooksdir)/instance-failover-post.d/gnt-networking-hook

	$(MKDIR_P) $(DESTDIR)$(hooksdir)/instance-add-post.d
	$(LN_S) $(progsdir)/gnt-networking-dnshook $(DESTDIR)$(hooksdir)/instance-add-post.d/gnt-networking-dnshook
	$(MKDIR_P) $(DESTDIR)$(hooksdir)/instance-modify-post.d
	$(LN_S) $(progsdir)/gnt-networking-dnshook $(DESTDIR)$(hooksdir)/instance-modify-post.d/gnt-networking-dnshook
	$(MKDIR_P) $(DESTDIR)$(hooksdir)/instance-rename-post.d
	$(LN_S) $(progsdir)/gnt-networking-dnshook $(DESTDIR)$(hooksdir)/instance-rename-post.d/gnt-networking-dnshook
	$(MKDIR_P) $(DESTDIR)$(hooksdir)/instance-remove-post.d
	$(LN_S) $(progsdir)/gnt-networking-dnshook $(DESTDIR)$(hooksdir)/instance-remove-post.d/gnt-networking-dnshook
	$(MKDIR_P) $(DESTDIR)$(hooksdir)/instance-reboot-post.d
	$(LN_S) $(progsdir)/gnt-networking-dnshook $(DESTDIR)$(hooksdir)/instance-reboot-post.d/gnt-networking-dnshook
	$(MKDIR_P) $(DESTDIR)$(hooksdir)/instance-startup-post.d
	$(LN_S) $(progsdir)/gnt-networking-dnshook $(DESTDIR)$(hooksdir)/instance-startup-post.d/gnt-networking-dnshook

	$(MKDIR_P) $(DESTDIR)$(networkdir)/if-up.d
	$(LN_S) $(progsdir)/vmrouter.ifup $(DESTDIR)$(networkdir)/if-up.d/vmrouter
	$(MKDIR_P) $(DESTDIR)$(networkdir)/if-down.d
	$(LN_S) $(progsdir)/vmrouter.ifdown $(DESTDIR)$(networkdir)/if-down.d/vmrouter

	$(LN_S) $(ganetidir)/kvm-ifup-custom $(DESTDIR)$(ganetidir)/kvm-vif-bridge

CLEANFILES = $(dist_ganeti_SCRIPTS) $(dist_common_DATA) $(dist_xen_SCRIPTS) \
	     $(srcdir)/gnt-networking-log $(srcdir)/gnt-networking-hook \
	     $(srcdir)/gnt-networking-dnshook


