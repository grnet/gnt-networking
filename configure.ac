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
