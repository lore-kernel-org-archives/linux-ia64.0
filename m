From: Alex Williamson <alex_williamson@hp.com>
Date: Fri, 17 Jan 2003 23:02:38 +0000
Subject: [Linux-ia64] [PATCH] 2.4/2.5 trivial
MIME-Version: 1
Content-Type: multipart/mixed; boundary="------------9584A187E028FC5AC5929E7C"
Message-Id: <marc-linux-ia64-105590709805717@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org

This is a multi-part message in MIME format.
--------------9584A187E028FC5AC5929E7C
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit


   Happened to notice the attached redundancy.  Thanks,

	Alex

--
Alex Williamson                                  Linux Development Lab
alex_williamson@hp.com                                 Hewlett Packard
970-898-9173                                          Fort Collins, CO
--------------9584A187E028FC5AC5929E7C
Content-Type: text/plain; charset=us-ascii;
 name="trivial.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="trivial.diff"

--- linux/arch/ia64/ia32/ia32_support.c~	2003-01-17 15:56:14.000000000 -0700
+++ linux/arch/ia64/ia32/ia32_support.c	2003-01-17 15:56:29.000000000 -0700
@@ -95,8 +95,6 @@
 	struct pt_regs *regs = ia64_task_regs(t);
 	int nr = smp_processor_id();	/* LDT and TSS depend on CPU number: */
 
-	nr = smp_processor_id();
-
 	eflag = t->thread.eflag;
 	fsr = t->thread.fsr;
 	fcr = t->thread.fcr;

--------------9584A187E028FC5AC5929E7C--


