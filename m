From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Wed, 26 Jan 2005 02:16:30 +0000
Subject: [patch] minor head.S cleanups
Message-Id: <16886.64894.932077.286431@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

While working on something else, I noticed that there are still some
CONFIG_IA64_EARLY_PRINTK bits left over in head.S, even though that
option is long gone.

While at it, I also added a "hint @pause" in the endless loop at the
end of _start.  Not that it ever should get executed, but if it ever
does, why waste power/cycles?

Signed-off-by: David Mosberger-Tang <davidm@hpl.hp.com>

=3D=3D=3D arch/ia64/kernel/head.S 1.30 vs edited =3D=3D--- 1.30/arch/ia64/k=
ernel/head.S	2005-01-11 15:45:50 -08:00
+++ edited/arch/ia64/kernel/head.S	2005-01-25 13:36:40 -08:00
@@ -5,7 +5,7 @@
  * to set up the kernel's global pointer and jump to the kernel
  * entry point.
  *
- * Copyright (C) 1998-2001, 2003 Hewlett-Packard Co
+ * Copyright (C) 1998-2001, 2003, 2005 Hewlett-Packard Co
  *	David Mosberger-Tang <davidm@hpl.hp.com>
  *	Stephane Eranian <eranian@hpl.hp.com>
  * Copyright (C) 1999 VA Linux Systems
@@ -232,21 +232,6 @@
 	;;
 (isBP)	st8 [r2]=3Dr28		// save the address of the boot param area passed b=
y the bootloader
=20
-#ifdef CONFIG_IA64_EARLY_PRINTK
-	.rodata
-alive_msg:
-	stringz "I'm alive and well\n"
-alive_msg_end:
-	.previous
-
-	alloc r2=3Dar.pfs,0,0,2,0
-	movl out0=3Dalive_msg
-	movl out1=3Dalive_msg_end-alive_msg-1
-	;;
-	br.call.sptk.many rp=EArly_printk
-1:	// force new bundle
-#endif /* CONFIG_IA64_EARLY_PRINTK */
-
 #ifdef CONFIG_SMP
 (isAP)	br.call.sptk.many rp=3Dstart_secondary
 .ret0:
@@ -267,7 +252,9 @@
 	;;
 	ld8 out0=3D[r3]
 	br.call.sptk.many b0=3Dconsole_print
-self:	br.sptk.many self		// endless loop
+
+self:	hint @pause
+	br.sptk.many self		// endless loop
 END(_start)
=20
 GLOBAL_ENTRY(ia64_save_debug_regs)
