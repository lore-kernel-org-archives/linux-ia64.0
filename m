From: Doug Chapman <doug.chapman@hp.com>
Date: Wed, 16 Jan 2008 20:21:48 +0000
Subject: [PATCH] fix userspace compile error in gcc_intrin.h
Message-Id: <1200514908.25522.37.camel@deimos.americas.hpqcorp.net>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Fixes userspace build errors when linux/ipv6.h is included such as
in the dhcpv6 package under fedora.  Likely causes other userspace
build errors as well.  I found this in akpm's tree from 2.6.18 but
could not find any case of anyone proposing it for the main tree.

Signed-off-by: Doug Chapman <doug.chapman@hp.com>
CC: Anderw Morton <akpm@osdl.org>


diff -up linux-2.6.23.ia64/include/asm-ia64/gcc_intrin.h.broken linux-2.6.23.ia64/include/asm-ia64/gcc_intrin.h
--- linux-2.6.23.ia64/include/asm-ia64/gcc_intrin.h.broken	2008-01-16 12:16:21.000000000 -0500
+++ linux-2.6.23.ia64/include/asm-ia64/gcc_intrin.h	2008-01-16 12:16:37.000000000 -0500
@@ -24,7 +24,9 @@
 extern void ia64_bad_param_for_setreg (void);
 extern void ia64_bad_param_for_getreg (void);
 
+#ifdef __KERNEL__
 register unsigned long ia64_r13 asm ("r13") __attribute_used__;
+#endif
 
 #define ia64_setreg(regnum, val)						\
 ({										\


