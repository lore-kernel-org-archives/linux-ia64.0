From: Matthew Wilcox <willy@debian.org>
Date: Sat, 23 Aug 2003 17:30:38 +0000
Subject: [PATCH] default to building compressed
Message-Id: <marc-linux-ia64-106166018214674@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


i386 defaults to building `bzImage' (as well as modules) if you just type
`make'.  This patch mirrors that on ia64 by building `compressed'.

Comments?

Index: arch/ia64/Makefile
=================================RCS file: /var/cvs/linux-2.6/arch/ia64/Makefile,v
retrieving revision 1.4
diff -u -p -r1.4 Makefile
--- a/arch/ia64/Makefile	23 Aug 2003 02:46:23 -0000	1.4
+++ b/arch/ia64/Makefile	23 Aug 2003 17:28:23 -0000
@@ -70,6 +70,8 @@ boot := arch/ia64/hp/sim/boot
 
 .PHONY: boot compressed check
 
+all: compressed
+
 compressed: vmlinux.gz
 
 vmlinux.gz: vmlinux
@@ -100,6 +102,6 @@ boot:	lib/lib.a vmlinux
 
 
 define archhelp
-  echo '  compressed	- Build compressed kernel image'
+  echo '* compressed	- Build compressed kernel image'
   echo '  boot		- Build vmlinux and bootloader for Ski simulator'
 endef

-- 
"It's not Hollywood.  War is real, war is primarily not about defeat or
victory, it is about death.  I've seen thousands and thousands of dead bodies.
Do you think I want to have an academic debate on this subject?" -- Robert Fisk
