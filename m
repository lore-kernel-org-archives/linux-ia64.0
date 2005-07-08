From: "H. J. Lu" <hjl@lucon.org>
Date: Fri, 08 Jul 2005 19:24:52 +0000
Subject: Fix a typo in arch/ia64/kernel/entry.S
Message-Id: <20050708192452.GA29642@lucon.org>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Both 2.4 and 2.6 kernels need this patch for the next binutils.


H.J.
----
--- linux-2.4.21/arch/ia64/kernel/entry.S.bad	2005-07-08 11:33:33.000000000 -0700
+++ linux-2.4.21/arch/ia64/kernel/entry.S	2005-07-08 12:14:00.000000000 -0700
@@ -970,7 +970,7 @@ ENTRY(sys_rt_sigreturn)
 	;;
 	adds out0,sp				// out0 = &sigscratch
 	br.call.sptk.many rp=ia64_rt_sigreturn
-.ret19:	.restore sp 0
+.ret19:	.restore sp,0
 	adds sp,sp
 	;;
 	ld8 r9=[sp]				// load new ar.unat
