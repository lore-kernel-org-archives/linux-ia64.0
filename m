From: jbarnes@sgi.com (Jesse Barnes)
Date: Tue, 14 Oct 2003 23:06:44 +0000
Subject: Re: [PATCH] sn2 module fix
Message-Id: <marc-linux-ia64-106617300403552@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106617270703267@msgid-missing>
In-Reply-To: <marc-linux-ia64-106617270703267@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, Oct 14, 2003 at 04:04:15PM -0700, Jesse Barnes wrote:
> Because we're the only platform with seperate in, out, and read
> routines, we have to include the file that defines them in our machvec
> header so that users of the functions will get the right defines and not
> use the non-inline function variants (which are only necessary for
> generic kernels).
> 
> Thanks,
> Jesse

How about I actually attach the patch?

Jesse

diff -Nru a/arch/ia64/sn/kernel/sn2/io.c b/arch/ia64/sn/kernel/sn2/io.c
--- a/arch/ia64/sn/kernel/sn2/io.c	Tue Oct 14 16:01:18 2003
+++ b/arch/ia64/sn/kernel/sn2/io.c	Tue Oct 14 16:01:18 2003
@@ -11,6 +11,8 @@
 
 #include <asm/sn/sn2/io.h>
 
+#ifdef CONFIG_IA64_GENERIC
+
 #undef __sn_inb
 #undef __sn_inw
 #undef __sn_inl
@@ -81,3 +83,5 @@
 {
 	return ___sn_readq (addr);
 }
+
+#endif
diff -Nru a/include/asm-ia64/machvec_sn2.h b/include/asm-ia64/machvec_sn2.h
--- a/include/asm-ia64/machvec_sn2.h	Tue Oct 14 16:01:18 2003
+++ b/include/asm-ia64/machvec_sn2.h	Tue Oct 14 16:01:18 2003
@@ -99,4 +99,6 @@
 #define platform_dma_sync_sg		sn_dma_sync_sg
 #define platform_dma_supported		sn_dma_supported
 
+#include <asm/sn/sn2/io.h>
+
 #endif /* _ASM_IA64_MACHVEC_SN2_H */
