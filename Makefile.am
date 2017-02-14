progsdir=$(libexecdir)/gnt-networking
commondir=$(datadir)/gnt-networking
fermdir=$(sysconfdir)/ferm
ganetidir=$(sysconfdir)/ganeti
hooksdir=$(ganetidir)/hooks
xendir=$(sysconfdir)/xen/scripts
networkdir=$(sysconfdir)/network


dist_progs_SCRIPTS = $(srcdir)/mac2eui64 $(srcdir)/runlocked \
		     $(srcdir)/vmrouter.ifup $(srcdir)/vmrouter.ifdown \
		     $(srcdir)/gnt-networking-hook \
		     $(srcdir)/gnt-networking-dnshook

dist_bin_SCRIPTS = $(srcdir)/prv-net-helper

dist_common_DATA = $(srcdir)/common.sh


dist_ferm_DATA = $(srcdir)/gnt-networking.ferm

dist_ganeti_SCRIPTS = $(srcdir)/kvm-ifup-custom $(srcdir)/kvm-ifdown-custom \
		      $(srcdir)/ifup-extra

dist_xen_SCRIPTS = $(srcdir)/vif-custom

edit = $(SED) \
       -e 's|@sysconfdir[@]|$(sysconfdir)|g' \
       -e 's|@localstatedir[@]|$(localstatedir)|g' \
       -e 's|@libexecdir[@]|$(libexecdir)|g' \
       -e 's|@datadir[@]|$(datadir)|g' \
       -e 's|@NFDHCPD_STATE_DIR[@]|$(NFDHCPD_STATE_DIR)|g' \
       -e 's|@GANETI_NIC_DIR[@]|$(GANETI_NIC_DIR)|g' \
       -e 's|@IPTABLES[@]|$(IPTABLES)|g' \
       -e 's|@IPTABLES_SAVE[@]|$(IPTABLES_SAVE)|g' \
       -e 's|@IP6TABLES[@]|$(IP6TABLES)|g' \
       -e 's|@IP6TABLES_SAVE[@]|$(IP6TABLES_SAVE)|g' \
       -e 's|@ARPTABLES[@]|$(ARPTABLES)|g' \
       -e 's|@ARPTABLES_SAVE[@]|$(ARPTABLES_SAVE)|g' \
       -e 's|@EBTABLES[@]|$(EBTABLES)|g' \
       -e 's|@NSUPDATE[@]|$(NSUPDATE)|g' \
       -e 's|@IP[@]|$(IP)|g' \
       -e 's|@ARPSEND[@]|$(ARPSEND)|g' \
       -e 's|@NDSEND[@]|$(NDSEND)|g' \
       -e 's|@BRCTL[@]|$(BRCTL)|g' \
       -e 's|@VCONFIG[@]|$(VCONFIG)|g'

%:%.in Makefile
	rm -f $@ $@.tmp
	srcdir=''; \
		test -f ./$@.in || srcdir=$(srcdir)/; \
		$(edit) $${srcdir}$@.in >$@.tmp
	mv $@.tmp $@

all-local: defaults

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
	     $(srcdir)/gnt-networking-hook $(srcdir)/gnt-networking-dnshook \
	     $(srcdir)/vmrouter.ifup $(srcdir)/vmrouter.ifdown \
	     $(srcdir)/prv-net-helper $(srcdir)/defaults

