From: Matthew Wilcox <willy@debian.org>
Date: Tue, 24 Feb 2004 15:33:59 +0000
Subject: [PATCH] make install
Message-Id: <20040224153359.GO25779@parcelfarce.linux.theplanet.co.uk>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


i386 has a 'make install' target that I find rather useful.  This
patch introduces it to ia64 too.  This time I remembered to fix it
up to apply with -p1 ;-)

Once http://bugs.debian.org/234557 is accepted, it'll work in Debian.
Until then, you may wish to add your own ~/bin/installkernel or
chmod a-x /sbin/installkernel.

Index: arch/ia64/Makefile
=================================RCS file: /var/cvs/linux-2.6/arch/ia64/Makefile,v
retrieving revision 1.9
diff -u -p -r1.9 Makefile
--- a/arch/ia64/Makefile	27 Jan 2004 18:44:19 -0000	1.9
+++ b/arch/ia64/Makefile	24 Feb 2004 15:26:43 -0000
@@ -104,9 +104,12 @@ include/asm-ia64/.offsets.h.stamp:
 boot:	lib/lib.a vmlinux
 	$(Q)$(MAKE) $(build)=$(boot) $@
 
+install: vmlinux.gz
+	sh $(srctree)/arch/ia64/install.sh $(KERNELRELEASE) $< System.map "$(INSTALL_PATH)"
 
 define archhelp
   echo '* compressed	- Build compressed kernel image'
+  echo '  install	- Install compressed kernel image'
   echo '  boot		- Build vmlinux and bootloader for Ski simulator'
   echo '* unwcheck	- Check vmlinux for invalid unwind info'
 endef
Index: arch/ia64/install.sh
=================================RCS file: arch/ia64/install.sh
diff -N arch/ia64/install.sh
--- /dev/null	1 Jan 1970 00:00:00 -0000
+++ b/arch/ia64/install.sh	24 Feb 2004 15:26:43 -0000
@@ -0,0 +1,40 @@
+#!/bin/sh
+#
+# arch/ia64/install.sh
+#
+# This file is subject to the terms and conditions of the GNU General Public
+# License.  See the file "COPYING" in the main directory of this archive
+# for more details.
+#
+# Copyright (C) 1995 by Linus Torvalds
+#
+# Adapted from code in arch/i386/boot/Makefile by H. Peter Anvin
+#
+# "make install" script for ia64 architecture
+#
+# Arguments:
+#   $1 - kernel version
+#   $2 - kernel image file
+#   $3 - kernel map file
+#   $4 - default install path (blank if root directory)
+#
+
+# User may have a custom install script
+
+if [ -x ~/bin/installkernel ]; then exec ~/bin/installkernel "$@"; fi
+if [ -x /sbin/installkernel ]; then exec /sbin/installkernel "$@"; fi
+
+# Default install - same as make zlilo
+
+if [ -f $4/vmlinuz ]; then
+	mv $4/vmlinuz $4/vmlinuz.old
+fi
+
+if [ -f $4/System.map ]; then
+	mv $4/System.map $4/System.old
+fi
+
+cat $2 > $4/vmlinuz
+cp $3 $4/System.map
+
+test -x /usr/sbin/elilo && /usr/sbin/elilo

-- 
"Next the statesmen will invent cheap lies, putting the blame upon 
the nation that is attacked, and every man will be glad of those
conscience-soothing falsities, and will diligently study them, and refuse
to examine any refutations of them; and thus he will by and by convince 
himself that the war is just, and will thank God for the better sleep 
he enjoys after this process of grotesque self-deception." -- Mark Twain
