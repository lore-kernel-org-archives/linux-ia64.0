From: Peter Chubb <peter@chubb.wattle.id.au>
Date: Fri, 06 Dec 2002 04:47:00 +0000
Subject: [Linux-ia64] Beta version of pfmon-2.0 available for testing
Message-Id: <marc-linux-ia64-105590709805510@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805507@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805507@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Thankyou thankyou thankyou for the man pages...

I had  a few difficulties  building debian packages from the source
tarballs.

1.  there are argument problems with debstd and dpkg-genchanges (fix
below)
2.  Two packages are created with overlapping contents for the library
packages... not what's wanted I think.

Here's a patch that fixes those things.

diff -r -u libpfm-2.0/debian/libpfm-dev.dirs libpfm_2.0/debian/libpfm-dev.dirs
--- libpfm-2.0/debian/libpfm-dev.dirs   2002-11-22 05:52:46.000000000 +1100
+++ libpfm_2.0/debian/libpfm-dev.dirs   2002-12-06 15:14:00.000000000 +1100
@@ -1,3 +1,3 @@
-/usr/share/doc
+/usr/share/doc/libpfm-dev
 /usr
 /usr/include
Only in libpfm_2.0/debian: libpfm-dev.examples
diff -r -u libpfm-2.0/debian/libpfm-dev.files libpfm_2.0/debian/libpfm-dev.files
--- libpfm-2.0/debian/libpfm-dev.files  2002-11-22 05:55:13.000000000 +1100
+++ libpfm_2.0/debian/libpfm-dev.files  2002-12-06 15:41:48.000000000 +1100
@@ -1,21 +1,51 @@
-/usr/share/doc/freesmpl.c
-/usr/share/doc/ita2_irr.c
-/usr/share/doc/ita2_opcode.c
-/usr/share/doc/ita2_rr.c
-/usr/share/doc/ita_btb.c
-/usr/share/doc/ita_irr.c
-/usr/share/doc/ita_opcode.c
-/usr/share/doc/ita_rr.c
-/usr/share/doc/notify_self.c
-/usr/share/doc/self.c
-/usr/share/doc/showreset.c
-/usr/share/doc/syst.c
-/usr/share/doc/task.c
-/usr/share/doc/whichpmu.c
-/usr/lib/libpfm.a
-/usr/include/perfmon/perfmon.h
-/usr/include/perfmon/pfmlib.h
-/usr/include/perfmon/pfmlib_itanium.h
-/usr/include/perfmon/pfmlib_itanium2.h
-/usr/include/perfmon/pfmlib_compiler.h
-/usr/include/perfmon/pfm_siginfo.h
+usr/share/doc/libpfm-dev/examples/freesmpl.c
+usr/share/doc/libpfm-dev/examples/ita2_irr.c
+usr/share/doc/libpfm-dev/examples/ita2_opcode.c
+usr/share/doc/libpfm-dev/examples/ita2_rr.c
+usr/share/doc/libpfm-dev/examples/ita_btb.c
+usr/share/doc/libpfm-dev/examples/ita_irr.c
+usr/share/doc/libpfm-dev/examples/ita_opcode.c
+usr/share/doc/libpfm-dev/examples/ita_rr.c
+usr/share/doc/libpfm-dev/examples/notify_self.c
+usr/share/doc/libpfm-dev/examples/self.c
+usr/share/doc/libpfm-dev/examples/showreset.c
+usr/share/doc/libpfm-dev/examples/syst.c
+usr/share/doc/libpfm-dev/examples/task.c
+usr/share/doc/libpfm-dev/examples/whichpmu.c
+usr/lib/libpfm.a
+usr/include/perfmon/perfmon.h
+usr/include/perfmon/pfmlib.h
+usr/include/perfmon/pfmlib_itanium.h
+usr/include/perfmon/pfmlib_itanium2.h
+usr/include/perfmon/pfmlib_generic.h
+usr/include/perfmon/pfmlib_compiler.h
+usr/include/perfmon/pfm_siginfo.h
+usr/share/man/man3/libpfm.3
+usr/share/man/man3/libpfm_itanium.3
+usr/share/man/man3/libpfm_itanium2.3
+usr/share/man/man3/pfm_dispatch_events.3
+usr/share/man/man3/pfm_find_event.3
+usr/share/man/man3/pfm_find_event_bycode.3
+usr/share/man/man3/pfm_find_event_bycode_next.3
+usr/share/man/man3/pfm_find_event_byname.3
+usr/share/man/man3/pfm_force_pmu.3
+usr/share/man/man3/pfm_get_event_code.3
+usr/share/man/man3/pfm_get_event_counters.3
+usr/share/man/man3/pfm_get_event_name.3
+usr/share/man/man3/pfm_get_first_event.3
+usr/share/man/man3/pfm_get_impl_counters.3
+usr/share/man/man3/pfm_get_impl_pmcs.3
+usr/share/man/man3/pfm_get_impl_pmds.3
+usr/share/man/man3/pfm_get_next_event.3
+usr/share/man/man3/pfm_get_num_counters.3
+usr/share/man/man3/pfm_get_pmu_name.3
+usr/share/man/man3/pfm_get_pmu_name_bytype.3
+usr/share/man/man3/pfm_get_pmu_type.3
+usr/share/man/man3/pfm_get_version.3
+usr/share/man/man3/pfm_initialize.3
+usr/share/man/man3/pfm_list_supported_pmus.3
+usr/share/man/man3/pfm_pmu_is_supported.3
+usr/share/man/man3/pfm_set_options.3
+usr/share/man/man3/pfm_start.3
+usr/share/man/man3/pfm_stop.3
+usr/share/man/man3/pfm_strerror.3
diff -r -u libpfm-2.0/debian/libpfm.dirs libpfm_2.0/debian/libpfm.dirs
--- libpfm-2.0/debian/libpfm.dirs       2002-11-22 05:50:57.000000000 +1100
+++ libpfm_2.0/debian/libpfm.dirs       2002-12-06 15:31:14.000000000 +1100
@@ -1 +1 @@
-/usr/lib
+usr/lib
diff -r -u libpfm-2.0/debian/libpfm.files libpfm_2.0/debian/libpfm.files
--- libpfm-2.0/debian/libpfm.files      2002-11-22 05:51:27.000000000 +1100
+++ libpfm_2.0/debian/libpfm.files      2002-12-06 15:31:17.000000000 +1100
@@ -1 +1 @@
-/usr/lib/libpfm.so.2.0.0
+usr/lib/libpfm.so.2.0.0
diff -r -u libpfm-2.0/debian/rules libpfm_2.0/debian/rules
--- libpfm-2.0/debian/rules     2002-11-21 14:01:38.000000000 +1100
+++ libpfm_2.0/debian/rules     2002-12-06 15:37:27.000000000 +1100
@@ -14,7 +14,7 @@
        -rm -f build
        -$(MAKE) distclean
        -rm -f `find . -name "*~"`
-       -rm -rf debian/tmp debian/files* core debian/substvars
+       -rm -rf debian/tmp debian/files* core debian/substvars debian/libpfm-dev debian/libpfm

 binary-indep: checkroot build
        $(checkdir)
@@ -26,12 +26,12 @@
        $(checkdir)
        -rm -rf debian/tmp
        install -d debian/tmp
-       cd debian/tmp && install -d `cat ../dirs`
+       cd debian/tmp && install -d `cat ../libpfm.dirs`
        $(MAKE) install DESTDIR=`pwd`/debian/tmp/usr
 # Must have debmake installed for this to work. Otherwise please copy
 # /usr/bin/debstd into the debian directory and change debstd to
debian/debstd
-       debstd ChangeLog README TODO
-       dpkg-gencontrol -isp
+       debstd ChangeLog TODO
+       dpkg-gencontrol -is -p${package}
        chown -R root.root debian/tmp
        chmod -R go=rX debian/tmp
        dpkg --build debian/tmp ..



--
Dr Peter Chubb				    peterc@gelato.unsw.edu.au
You are lost in a maze of BitKeeper repositories, all almost the same.


