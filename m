From: jbarnes@sgi.com (Jesse Barnes)
Date: Thu, 05 Feb 2004 20:23:35 +0000
Subject: [PATCH] fix readX_relaxed machine vectors for ia64
Message-Id: <20040205202335.GA6551@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: torvalds@osdl.org, akpm@osdl.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org

I left out some of the necessary machine vector magic in my
readX_relaxed patch, which broke the ia64 generic build.  Please apply
this patch to the BK tree to fix it.

Thanks,
Jesse

=== arch/ia64/lib/io.c 1.6 vs edited ==--- 1.6/arch/ia64/lib/io.c	Mon Jan  5 07:30:22 2004
+++ edited/arch/ia64/lib/io.c	Thu Feb  5 12:14:22 2004
@@ -65,6 +65,10 @@
 #undef __ia64_readw
 #undef __ia64_readl
 #undef __ia64_readq
+#undef __ia64_readb_relaxed
+#undef __ia64_readw_relaxed
+#undef __ia64_readl_relaxed
+#undef __ia64_readq_relaxed
 #undef __ia64_writeb
 #undef __ia64_writew
 #undef __ia64_writel
@@ -126,6 +130,30 @@
 
 unsigned long
 __ia64_readq (void *addr)
+{
+	return ___ia64_readq (addr);
+}
+
+unsigned char
+__ia64_readb_relaxed (void *addr)
+{
+	return ___ia64_readb (addr);
+}
+
+unsigned short
+__ia64_readw_relaxed (void *addr)
+{
+	return ___ia64_readw (addr);
+}
+
+unsigned int
+__ia64_readl_relaxed (void *addr)
+{
+	return ___ia64_readl (addr);
+}
+
+unsigned long
+__ia64_readq_relaxed (void *addr)
 {
 	return ___ia64_readq (addr);
 }
=== include/asm-ia64/machvec_init.h 1.6 vs edited ==--- 1.6/include/asm-ia64/machvec_init.h	Sat May 10 02:28:47 2003
+++ edited/include/asm-ia64/machvec_init.h	Thu Feb  5 11:40:56 2004
@@ -16,6 +16,10 @@
 extern ia64_mv_readw_t __ia64_readw;
 extern ia64_mv_readl_t __ia64_readl;
 extern ia64_mv_readq_t __ia64_readq;
+extern ia64_mv_readb_t __ia64_readb_relaxed;
+extern ia64_mv_readw_t __ia64_readw_relaxed;
+extern ia64_mv_readl_t __ia64_readl_relaxed;
+extern ia64_mv_readq_t __ia64_readq_relaxed;
 
 #define MACHVEC_HELPER(name)									\
  struct ia64_machine_vector machvec_##name __attribute__ ((unused, __section__ (".machvec")))	\
