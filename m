From: Gustavo Niemeyer <niemeyer@conectiva.com>
Date: Tue, 10 Apr 2001 11:50:33 +0000
Subject: Re: [Linux-ia64] strace / ptrace_offsets.h
MIME-Version: 1
Content-Type: multipart/mixed; boundary="y0ulUmNC+osPPQO6"
Message-Id: <marc-linux-ia64-105590693005387@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590693005384@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590693005384@msgid-missing>
To: linux-ia64@vger.kernel.org

--y0ulUmNC+osPPQO6
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi Andreas!

[...]
> |> This problem seems to be back with strace 4.3 and kernel 2.4.3. In this
> |> case, which one should be fixed??
> 
> Use the strace source from the ia64_0 branch on
> cvs.strace.sourceforge.net.

I've been using it for some time, but it is not up to date with the
latest strace release (4.3). Anyway, your answer means that the problem
is probably with strace itself. Attached is a patch I've used to build
it.

Thanks!!

-- 
Gustavo Niemeyer

[ 2AAC 7928 0FBF 0299 5EB5  60E2 2253 B29A 6664 3A0C ]

--y0ulUmNC+osPPQO6
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="strace-4.3-ia64.patch"

--- strace-4.3/process.c.ia64	Wed Mar 28 17:29:17 2001
+++ strace-4.3/process.c	Tue Apr 10 08:32:30 2001
@@ -1989,16 +1989,10 @@
 	{ PT_F27, "f27" }, { PT_F28, "f28" }, { PT_F29, "f29" },
 	{ PT_F30, "f30" }, { PT_F31, "f31" }, { PT_R4, "r4" },
 	{ PT_R5, "r5" }, { PT_R6, "r6" }, { PT_R7, "r7" },
-	{ PT_K_B0, "kb0" },
 	{ PT_B1, "b1" }, { PT_B2, "b2" }, { PT_B3, "b3" },
 	{ PT_B4, "b4" }, { PT_B5, "b5" },
-	{ PT_K_AR_PFS, "kar.pfs" },
-	{ PT_AR_LC, "ar.lc" }, { PT_K_AR_UNAT, "kar.unat" },
-	{ PT_K_AR_RNAT, "kar.rnat" }, { PT_K_AR_BSPSTORE, "kar.bspstore" },
-	{ PT_K_PR, "k.pr" },
 	/* pt_regs */
 	{ PT_CR_IPSR, "cr.ipsr" }, { PT_CR_IIP, "cr.iip" },
-	{ PT_CR_IFS, "cr.ifs" }, { PT_AR_UNAT, "ar.unat" },
 	{ PT_AR_PFS, "ar.pfs" }, { PT_AR_RSC, "ar.rsc" },
 	{ PT_AR_RNAT, "ar.rnat" }, { PT_AR_BSPSTORE, "ar.bspstore" },
 	{ PT_PR, "pr" }, { PT_B6, "b6" }, { PT_AR_BSP, "ar.bsp" },
--- strace-4.3/signal.c.ia64	Wed Mar 28 17:29:17 2001
+++ strace-4.3/signal.c	Tue Apr 10 08:38:07 2001
@@ -84,7 +84,9 @@
 	int			si_mask;
 } m_siginfo_t;
 #else
+#ifndef IA64
 #include <asm/sigcontext.h>
+#endif
 #endif /* SPARC */
 #else /* !HAVE_ASM_SIGCONTEXT_H */
 #ifdef I386

--y0ulUmNC+osPPQO6--

