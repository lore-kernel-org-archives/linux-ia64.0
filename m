From: "Luck, Tony" <tony.luck@intel.com>
Date: Fri, 09 Nov 2001 00:54:26 +0000
Subject: [Linux-ia64] PATCH: fix CONFIG_IA64_EARLY_PRINTK
Message-Id: <marc-linux-ia64-105590698805458@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

This was broken in 2.4.10 when "early_printk()" was given
an extra argument to specify the length of the string to
print, but head.S wasn't updated to pass such an argument.
(Oddly enough the "alloc" call in head.S sets up two 'out'
registers already).

Here is the patch:

diff -ru ../../REF/2.4.14-ia64-011105/arch/ia64/config.in
linux/arch/ia64/config.in
--- ../../REF/2.4.14-ia64-011105/arch/ia64/config.in	Tue Nov  6 11:34:13
2001
+++ linux/arch/ia64/config.in	Thu Nov  8 16:41:15 2001
@@ -266,8 +266,7 @@
    bool '  Disable VHPT' CONFIG_DISABLE_VHPT
    bool '  Magic SysRq key' CONFIG_MAGIC_SYSRQ
=20
-# early printk is currently broken for SMP: the secondary processors get
stuck...
-#   bool '  Early printk support (requires VGA!)' CONFIG_IA64_EARLY_PRINTK
+   bool '  Early printk support (requires VGA!)' CONFIG_IA64_EARLY_PRINTK
=20
    bool '  Debug memory allocations' CONFIG_DEBUG_SLAB
    bool '  Spinlock debugging' CONFIG_DEBUG_SPINLOCK
diff -ru ../../REF/2.4.14-ia64-011105/arch/ia64/kernel/head.S
linux/arch/ia64/kernel/head.S
--- ../../REF/2.4.14-ia64-011105/arch/ia64/kernel/head.S	Tue Nov  6
11:34:13 2001
+++ linux/arch/ia64/kernel/head.S	Thu Nov  8 16:29:34 2001
@@ -180,10 +180,12 @@
 	.rodata
 alive_msg:
 	stringz "I'm alive and well\n"
+alive_msg_end:
 	.previous
=20
 	alloc r2=3Dar.pfs,0,0,2,0
 	movl out0=3Dalive_msg
+	movl out1=3Dalive_msg_end-alive_msg-1
 	;;
 	br.call.sptk.many rp=EArly_printk
 1:	// force new bundle

