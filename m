From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Tue, 29 Mar 2005 23:01:00 +0000
Subject: RE: syscall improvement patch [9/12]
Message-Id: <16969.56876.357092.411876@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200503240051.j2O0pNx1022310@napali.hpl.hp.com>
In-Reply-To: <200503240051.j2O0pNx1022310@napali.hpl.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Wed, 30 Mar 2005 04:25:15 +0800, "Zhang, Yanmin" <yanmin.zhang@intel.com> said:

  Yanmin> The patch has a problem.  r29 is used to store psr, but it
  Yanmin> should get psr value after rsm psr.i. You patch reverses the
  Yanmin> sequence. If there is an interrupt happening and psr might
  Yanmin> be changed, such like IA64_PSR_MFH.

Argh, so I re-introduced the bug you guys fixed once before
already. ;-(

How about the attached patch?  It does cost a cycle on the
light-weight syscall path, but doesn't slow down the EPC-based
heavy-weight syscall path.

Unfortunately, between 2.6.12 and the current tree (with Linus' latest
changes), we seem to have some cycles otherwise.  Specifically, I'm
seeing:

                                          getpid          getuid
                                        EPC     BREAK   EPC     BREAK
        2.6.12                          38      207     180     206
        2.6.12-rc1                      39      211     188     210
        2.6.12-rc1 with patch below     40      211     188     210

So between 2.6.12 and 2.6.12-rc1 we seem to have lost 4 cycles on the
BREAK path and 8 cycles on the EPC getuid() path.  It's possible that
this is just noise due to code-layout changes.  I'll see if I can find
some time to confirm that.

	--david

=== arch/ia64/kernel/gate.S 1.27 vs edited ==--- 1.27/arch/ia64/kernel/gate.S	2005-03-24 14:06:39 -08:00
+++ edited/arch/ia64/kernel/gate.S	2005-03-29 13:58:15 -08:00
@@ -77,7 +77,7 @@
 	epc					// B	causes split-issue
 }
 	;;
-	rsm psr.be				// M2 (5 cyc to srlz.d)
+	rsm psr.be | psr.i			// M2 (5 cyc to srlz.d)
 	LOAD_FSYSCALL_TABLE(r14)		// X
 	;;
 	mov r16=IA64_KR(CURRENT)		// M2 (12 cyc)
@@ -98,15 +98,14 @@
 	nop.i 0
 	;;
 	nop.m 0
-(p6)	mov b7=r18				// I0
 (p6)	tbit.z.unc p8,p0=r18,0			// I0 (dual-issues with "mov b7=r18"!)
-
-	nop.m 0
 	nop.i 0
+	;;
+(p8)	ssm psr.i
+(p6)	mov b7=r18				// I0
 (p8)	br.dptk.many b7				// B
 
 	mov r27=ar.rsc				// M2 (12 cyc)
-(p6)	rsm psr.i				// M2
 /*
  * brl.cond doesn't work as intended because the linker would convert this branch
  * into a branch to a PLT.  Perhaps there will be a way to avoid this with some
@@ -123,7 +122,7 @@
 #else
 	BRL_COND_FSYS_BUBBLE_DOWN(p6)
 #endif
-
+	ssm psr.i
 	mov r10=-1
 (p10)	mov r8=EINVAL
 (p9)	mov r8=ENOSYS
