From: "H. J. Lu" <hjl@lucon.org>
Date: Wed, 02 Feb 2005 21:18:28 +0000
Subject: PATCH: Fix 2.4 kernel ia64 directives
Message-Id: <20050202211828.GA7071@lucon.org>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

The new ia64 assembler caught a few directive bugs. Here is the patch.


H.J.
--- linux-2.4.21/arch/ia64/hp/sim/hpsim_setup.c.unwind	2002-11-28 15:53:09.000000000 -0800
+++ linux-2.4.21/arch/ia64/hp/sim/hpsim_setup.c	2005-02-02 11:59:55.000000000 -0800
@@ -35,7 +35,7 @@ asm (".text\n"
      "mov r15=r36\n"
      "break 0x80001\n"
      "br.ret.sptk.many rp\n"
-     ".endp\n");
+     ".endp ia64_ssc\n");
 
 void
 ia64_ssc_connect_irq (long intr, long irq)
--- linux-2.4.21/arch/ia64/kernel/ivt.S.unwind	2005-02-02 11:37:59.000000000 -0800
+++ linux-2.4.21/arch/ia64/kernel/ivt.S	2005-02-02 11:57:34.000000000 -0800
@@ -527,7 +527,7 @@ ENTRY(dirty_bit)
 #endif
 	mov pr=r31,-1				// restore pr
 	rfi
-END(idirty_bit)
+END(dirty_bit)
 
 	.align 1024
 /////////////////////////////////////////////////////////////////////////////////////////
