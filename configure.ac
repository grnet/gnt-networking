AC_PREREQ(2.59)
m4_include([version.m4])
AC_INIT(gnt-networking, devflow_version,,,https://github.com/grnet/gnt-networking)

AC_CONFIG_AUX_DIR(autotools)
AC_CONFIG_SRCDIR(configure)

AM_INIT_AUTOMAKE([1.9 foreign tar-ustar -Wall -Wno-portability subdir-objects])

# --with-ganeti-nic-dir
AC_ARG_WITH([ganeti_nic_dir],
  [AS_HELP_STRING([--with-ganeti-nic-dir=DIR],
                  [DIR containing ganeti NIC informataion in case of Xen [RUNSTATEDIR/ganeti/xen-hypervisor/nic]])],
  [ganeti_nic_dir="$withval"],
  [ganeti_nic_dir="$runstatedir/ganeti/xen-hypervisor/nic"])

AC_SUBST(GANETI_NIC_DIR, $ganeti_nic_dir)

# --with-nfdhcpd-state-dir
AC_ARG_WITH([nfdhcpd_state_dir],
  [AS_HELP_STRING([--with-nfdhcpd-state-dir=DIR],
                  [DIR containing nfdhcpd binding files [LOCALSTATEDIR/lib/nfdhcpd]])],
  [nfdhcpd_state_dir="$withval"],
  [nfdhcpd_state_dir="$localstatedir/lib/nfdhcpd"])

AC_SUBST(NFDHCPD_STATE_DIR, "$nfdhcpd_state_dir")

# --with-arptables
AC_ARG_WITH([arptables],
  AS_HELP_STRING([--with-arptables=FULLPATH],
                  [set full path to arptables executable [auto]]),
  [ARPTABLES="$withval"])
if test -n "$ARPTABLES"; then
    # user-supplied value
    AC_MSG_CHECKING([user-supplied arptables executable])
    if test -f "$ARPTABLES"; then
        :
    else
        AC_MSG_RESULT([non-existing])
        AC_MSG_ERROR([invalid value $ARPTABLES for arptables executable])
    fi
    if test -x "$ARPTABLES"; then
        :
    else
        AC_MSG_RESULT([non-executable])
        AC_MSG_ERROR([invalid value $ARPTABLES for arptables executable])
    fi
    AC_MSG_RESULT([$ARPTABLES])
else
    AC_PATH_PROG(ARPTABLES, [arptables], [], [$PATH:/usr/sbin:/sbin])
    if test -z "$ARPTABLES" ; then
        AC_MSG_ERROR([arptables not found in $PATH:/usr/sbin:/sbin])
    fi
fi

# --with-arptables-save
AC_ARG_WITH([arptables-save],
  AS_HELP_STRING([--with-arptables-save=FULLPATH],
                  [set full path to arptables-save executable [auto]]),
  [ARPTABLES_SAVE="$withval"])
if test -n "$ARPTABLES_SAVE"; then
    # user-supplied value
    AC_MSG_CHECKING([user-supplied arptables-save executable])
    if test -f "$ARPTABLES_SAVE"; then
        :
    else
        AC_MSG_RESULT([non-existing])
        AC_MSG_ERROR([invalid value $ARPTABLES_SAVE for arptables-save executable])
    fi
    if test -x "$ARPTABLES_SAVE"; then
        :
    else
        AC_MSG_RESULT([non-executable])
        AC_MSG_ERROR([invalid value $ARPTABLES_SAVE for arptables-save executable])
    fi
    AC_MSG_RESULT([$ARPTABLES_SAVE])
else
    AC_PATH_PROG(ARPTABLES_SAVE, [arptables-save], [], [$PATH:/usr/sbin:/sbin])
    if test -z "$ARPTABLES_SAVE" ; then
        AC_MSG_ERROR([arptables-save not found in $PATH:/usr/sbin:/sbin])
    fi
fi

# --with-brctl
AC_ARG_WITH([brctl],
  AS_HELP_STRING([--with-brctl=FULLPATH],
                  [set full path to brctl executable [auto]]),
  [BRCTL="$withval"])
if test -n "$BRCTL"; then
    # user-supplied value
    AC_MSG_CHECKING([user-supplied brctl executable])
    if test -f "$BRCTL"; then
        :
    else
        AC_MSG_RESULT([non-existing])
        AC_MSG_ERROR([invalid value $BRCTL for brctl executable])
    fi
    if test -x "$BRCTL"; then
        :
    else
        AC_MSG_RESULT([non-executable])
        AC_MSG_ERROR([invalid value $BRCTL for brctl executable])
    fi
    AC_MSG_RESULT([$BRCTL])
else
    AC_PATH_PROG(BRCTL, [brctl], [], [$PATH:/usr/sbin:/sbin])
    if test -z "$BRCTL" ; then
        AC_MSG_ERROR([brctl not found in $PATH:/usr/sbin:/sbin])
    fi
fi

# --with-ebtables
AC_ARG_WITH([ebtables],
  AS_HELP_STRING([--with-ebtables=FULLPATH],
                  [set full path to ebtables executable [auto]]),
  [EBTABLES="$withval"])
if test -n "$EBTABLES"; then
    # user-supplied value
    AC_MSG_CHECKING([user-supplied ebtables executable])
    if test -f "$EBTABLES"; then
        :
    else
        AC_MSG_RESULT([non-existing])
        AC_MSG_ERROR([invalid value $EBTABLES for ebtables executable])
    fi
    if test -x "$EBTABLES"; then
        :
    else
        AC_MSG_RESULT([non-executable])
        AC_MSG_ERROR([invalid value $EBTABLES for ebtables executable])
    fi
    AC_MSG_RESULT([$EBTABLES])
else
    AC_PATH_PROG(EBTABLES, [ebtables], [], [$PATH:/usr/sbin:/sbin])
    if test -z "$EBTABLES" ; then
        AC_MSG_ERROR([ebtables not found in $PATH:/usr/sbin:/sbin])
    fi
fi

# --with-ip
AC_ARG_WITH([ip],
  AS_HELP_STRING([--with-ip=FULLPATH],
                  [set full path to ip executable [auto]]),
  [IP="$withval"])
if test -n "$IP"; then
    # user-supplied value
    AC_MSG_CHECKING([user-supplied ip executable])
    if test -f "$IP"; then
        :
    else
        AC_MSG_RESULT([non-existing])
        AC_MSG_ERROR([invalid value $IP for ip executable])
    fi
    if test -x "$IP"; then
        :
    else
        AC_MSG_RESULT([non-executable])
        AC_MSG_ERROR([invalid value $IP for ip executable])
    fi
    AC_MSG_RESULT([$IP])
else
    AC_PATH_PROG(IP, [ip], [], [$PATH:/usr/sbin:/sbin])
    if test -z "$IP" ; then
        AC_MSG_ERROR([ip not found in $PATH:/usr/sbin:/sbin])
    fi
fi

# --with-iptables
AC_ARG_WITH([iptables],
  AS_HELP_STRING([--with-iptables=FULLPATH],
                  [set full path to iptables executable [auto]]),
  [IPTABLES="$withval"])
if test -n "$IPTABLES"; then
    # user-supplied value
    AC_MSG_CHECKING([user-supplied iptables executable])
    if test -f "$IPTABLES"; then
        :
    else
        AC_MSG_RESULT([non-existing])
        AC_MSG_ERROR([invalid value $IPTABLES for iptables executable])
    fi
    if test -x "$IPTABLES"; then
        :
    else
        AC_MSG_RESULT([non-executable])
        AC_MSG_ERROR([invalid value $IPTABLES for iptables executable])
    fi
    AC_MSG_RESULT([$IPTABLES])
else
    AC_PATH_PROG(IPTABLES, [iptables], [], [$PATH:/usr/sbin:/sbin])
    if test -z "$IPTABLES" ; then
        AC_MSG_ERROR([iptables not found in $PATH:/usr/sbin:/sbin])
    fi
fi

# --with-iptables-save
AC_ARG_WITH([iptables-save],
  AS_HELP_STRING([--with-iptables-save=FULLPATH],
                  [set full path to iptables-save executable [auto]]),
  [IPTABLES_SAVE="$withval"])
if test -n "$IPTABLES_SAVE"; then
    # user-supplied value
    AC_MSG_CHECKING([user-supplied iptables-save executable])
    if test -f "$IPTABLES_SAVE"; then
        :
    else
        AC_MSG_RESULT([non-existing])
        AC_MSG_ERROR([invalid value $IPTABLES_SAVE for iptables-save executable])
    fi
    if test -x "$IPTABLES_SAVE"; then
        :
    else
        AC_MSG_RESULT([non-executable])
        AC_MSG_ERROR([invalid value $IPTABLES_SAVE for iptables-save executable])
    fi
    AC_MSG_RESULT([$IPTABLES_SAVE])
else
    AC_PATH_PROG(IPTABLES_SAVE, [iptables-save], [], [$PATH:/usr/sbin:/sbin])
    if test -z "$IPTABLES_SAVE" ; then
        AC_MSG_ERROR([iptables-save not found in $PATH:/usr/sbin:/sbin])
    fi
fi

# --with-ip6tables
AC_ARG_WITH([ip6tables],
  AS_HELP_STRING([--with-ip6tables=FULLPATH],
                  [set full path to ip6tables executable [auto]]),
  [IP6TABLES="$withval"])
if test -n "$IP6TABLES"; then
    # user-supplied value
    AC_MSG_CHECKING([user-supplied ip6tables executable])
    if test -f "$IP6TABLES"; then
        :
    else
        AC_MSG_RESULT([non-existing])
        AC_MSG_ERROR([invalid value $IP6TABLES for ip6tables executable])
    fi
    if test -x "$IP6TABLES"; then
        :
    else
        AC_MSG_RESULT([non-executable])
        AC_MSG_ERROR([invalid value $IP6TABLES for ip6tables executable])
    fi
    AC_MSG_RESULT([$IP6TABLES])
else
    AC_PATH_PROG(IP6TABLES, [ip6tables], [], [$PATH:/usr/sbin:/sbin])
    if test -z "$IP6TABLES" ; then
        AC_MSG_ERROR([ip6tables not found in $PATH:/usr/sbin:/sbin])
    fi
fi

# --with-ip6tables-save
AC_ARG_WITH([ip6tables-save],
  AS_HELP_STRING([--with-ip6tables-save=FULLPATH],
                  [set full path to ip6tables-save executable [auto]]),
  [IP6TABLES_SAVE="$withval"])
if test -n "$IP6TABLES_SAVE"; then
    # user-supplied value
    AC_MSG_CHECKING([user-supplied ip6tables-save executable])
    if test -f "$IP6TABLES_SAVE"; then
        :
    else
        AC_MSG_RESULT([non-existing])
        AC_MSG_ERROR([invalid value $IP6TABLES_SAVE for ip6tables-save executable])
    fi
    if test -x "$IP6TABLES_SAVE"; then
        :
    else
        AC_MSG_RESULT([non-executable])
        AC_MSG_ERROR([invalid value $IP6TABLES_SAVE for ip6tables-save executable])
    fi
    AC_MSG_RESULT([$IP6TABLES_SAVE])
else
    AC_PATH_PROG(IP6TABLES_SAVE, [ip6tables-save], [], [$PATH:/usr/sbin:/sbin])
    if test -z "$IP6TABLES_SAVE" ; then
        AC_MSG_ERROR([ip6tables-save not found in $PATH:/usr/sbin:/sbin])
    fi
fi

# --with-arpsend
AC_ARG_WITH([arpsend],
  AS_HELP_STRING([--with-arpsend=FULLPATH],
                  [set full path to arpsend executable [auto]]),
  [ARPSEND="$withval"])
if test -n "$ARPSEND"; then
    # user-supplied value
    AC_MSG_CHECKING([user-supplied arpsend executable])
    if test -f "$ARPSEND"; then
        :
    else
        AC_MSG_RESULT([non-existing])
        AC_MSG_ERROR([invalid value $ARPSEND for arpsend executable])
    fi
    if test -x "$ARPSEND"; then
        :
    else
        AC_MSG_RESULT([non-executable])
        AC_MSG_ERROR([invalid value $ARPSEND for arpsend executable])
    fi
    AC_MSG_RESULT([$ARPSEND])
else
    AC_PATH_PROG(ARPSEND, [arpsend], [], [$PATH:/usr/sbin:/sbin])
    if test -z "$ARPSEND" ; then
        AC_MSG_ERROR([arpsend not found in $PATH:/usr/sbin:/sbin])
    fi
fi

# --with-ndsend
AC_ARG_WITH([ndsend],
  AS_HELP_STRING([--with-ndsend=FULLPATH],
                  [set full path to ndsend executable [auto]]),
  [NDSEND="$withval"])
if test -n "$NDSEND"; then
    # user-supplied value
    AC_MSG_CHECKING([user-supplied ndsend executable])
    if test -f "$NDSEND"; then
        :
    else
        AC_MSG_RESULT([non-existing])
        AC_MSG_ERROR([invalid value $NDSEND for ndsend executable])
    fi
    if test -x "$NDSEND"; then
        :
    else
        AC_MSG_RESULT([non-executable])
        AC_MSG_ERROR([invalid value $NDSEND for ndsend executable])
    fi
    AC_MSG_RESULT([$NDSEND])
else
    AC_PATH_PROG(NDSEND, [ndsend], [], [$PATH:/usr/sbin:/sbin])
    if test -z "$NDSEND" ; then
        AC_MSG_ERROR([ndsend not found in $PATH:/usr/sbin:/sbin])
    fi
fi

# --with-nsupdate
AC_ARG_WITH([nsupdate],
  AS_HELP_STRING([--with-nsupdate=FULLPATH],
                  [set full path to nsupdate executable [auto]]),
  [NSUPDATE="$withval"])
if test -n "$NSUPDATE"; then
    # user-supplied value
    AC_MSG_CHECKING([user-supplied nsupdate executable])
    if test -f "$NSUPDATE"; then
        :
    else
        AC_MSG_RESULT([non-existing])
        AC_MSG_ERROR([invalid value $NSUPDATE for nsupdate executable])
    fi
    if test -x "$NSUPDATE"; then
        :
    else
        AC_MSG_RESULT([non-executable])
        AC_MSG_ERROR([invalid value $NSUPDATE for nsupdate executable])
    fi
    AC_MSG_RESULT([$NSUPDATE])
else
    AC_PATH_PROG(NSUPDATE, [nsupdate], [], [$PATH:/usr/sbin:/sbin])
    if test -z "$NSUPDATE" ; then
        AC_MSG_ERROR([nsupdate not found in $PATH:/usr/sbin:/sbin])
    fi
fi

# --with-vconfig
AC_ARG_WITH([vconfig],
  AS_HELP_STRING([--with-vconfig=FULLPATH],
                  [set full path to vconfig executable [auto]]),
  [VCONFIG="$withval"])
if test -n "$VCONFIG"; then
    # user-supplied value
    AC_MSG_CHECKING([user-supplied vconfig executable])
    if test -f "$VCONFIG"; then
        :
    else
        AC_MSG_RESULT([non-existing])
        AC_MSG_ERROR([invalid value $VCONFIG for vconfig executable])
    fi
    if test -x "$VCONFIG"; then
        :
    else
        AC_MSG_RESULT([non-executable])
        AC_MSG_ERROR([invalid value $VCONFIG for vconfig executable])
    fi
    AC_MSG_RESULT([$VCONFIG])
else
    AC_PATH_PROG(VCONFIG, [vconfig], [], [$PATH:/usr/sbin:/sbin])
    if test -z "$VCONFIG" ; then
        AC_MSG_ERROR([vconfig not found in $PATH:/usr/sbin:/sbin])
    fi
fi

# Check common programs
AC_PROG_INSTALL
AC_PROG_LN_S
AC_PROG_AWK
AC_PROG_MKDIR_P
AC_PROG_SED

AC_CONFIG_FILES([
    Makefile
])
AC_OUTPUT

# vim: set sta sts=4 shiftwidth=4 sw=4 et ai :
