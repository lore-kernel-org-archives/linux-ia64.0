From: Keith Owens <kaos@sgi.com>
Date: Sun, 20 Jul 2003 10:03:52 +0000
Subject: [patch] 2.4.21-ia64-030702 arch/ia64/Makefile
Message-Id: <marc-linux-ia64-105869579516951@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Delete some generated ia64 files that were being left by make mrproper.

--- 2.4.21/arch/ia64/Makefile	2003-07-20 20:01:57.000000000 +1000
+++ 2.4.21/arch/ia64/Makefile	2003-07-20 20:01:23.000000000 +1000
@@ -141,7 +141,7 @@
 	arch/ia64/scripts/unwcheck.sh vmlinux
 
 archmrproper:
-	rm -f arch/$(ARCH)/vmlinux.lds
+	rm -f arch/$(ARCH)/vmlinux.lds vmlinux-tmp vmlinux.gz
 	@$(MAKE) -C arch/$(ARCH)/tools mrproper
 
 archdep: include/config/MARKER

