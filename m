From: Alex Williamson <alex_williamson@hp.com>
Date: Thu, 03 Apr 2003 17:53:27 +0000
Subject: [Linux-ia64] [PATCH] 3/4 trivial generic fix
MIME-Version: 1
Content-Type: multipart/mixed; boundary="------------1681CF59BC5FF7EC149ECDF8"
Message-Id: <marc-linux-ia64-105590723705398@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705395@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705395@msgid-missing>
To: linux-ia64@vger.kernel.org

This is a multi-part message in MIME format.
--------------1681CF59BC5FF7EC149ECDF8
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit


   Patch 3 is a trivial build fix for the generic kernel target.
Thanks,

	Alex

--
Alex Williamson                             HP Linux & Open Source Lab
--------------1681CF59BC5FF7EC149ECDF8
Content-Type: text/plain; charset=us-ascii;
 name="patch-03.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="patch-03.diff"

diff -urN linux-2.5.64/arch/ia64/boot/Makefile linux-work/arch/ia64/boot/Makefile
--- linux-2.5.64/arch/ia64/boot/Makefile	Tue Mar  4 20:29:23 2003
+++ linux-work/arch/ia64/boot/Makefile	Tue Apr  1 09:19:53 2003
@@ -11,7 +11,6 @@
 EXTRA_TARGETS := vmlinux.bin vmlinux.gz
 
 targets-$(CONFIG_IA64_HP_SIM)  += bootloader
-targets-$(CONFIG_IA64_GENERIC) += bootloader
 EXTRA_TARGETS += $(sort $(targets-y))
 
 quiet_cmd_cptotop = LN      $@

--------------1681CF59BC5FF7EC149ECDF8--


