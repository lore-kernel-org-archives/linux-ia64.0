From: Bill Nottingham <notting@redhat.com>
Date: Fri, 15 Dec 2000 17:54:32 +0000
Subject: [Linux-ia64] Re: kernel update (relative to 2.4.0-test12)
MIME-Version: 1
Content-Type: multipart/mixed; boundary="UlVJffcvxoiEqYs2"
Message-Id: <marc-linux-ia64-105590678205855@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org

--UlVJffcvxoiEqYs2
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

David Mosberger (davidm@hpl.hp.com) said: 
> The latest IA-64 patch is now available at:
> 
>  ftp://ftp.kernel.org/pub/linux/kernel/port/pub/linux/kernel/ports/ia64/
> 
> in files linux-2.4.0-test12-ia64-001214.diff*

Patch attached; fixes an undefined symbol if IDE is built modular.

Bill

--UlVJffcvxoiEqYs2
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="linux-2.4.0-test12-ia64-idesym.patch"

--- linux/arch/ia64/kernel/ia64_ksyms.c.foo	Thu Dec 14 18:54:41 2000
+++ linux/arch/ia64/kernel/ia64_ksyms.c	Thu Dec 14 18:55:20 2000
@@ -28,6 +28,9 @@
 EXPORT_SYMBOL(pci_alloc_consistent);
 EXPORT_SYMBOL(pci_free_consistent);
 
+#include <asm/hw_irq.h>
+EXPORT_SYMBOL(isa_irq_to_vector_map);
+
 #include <linux/in6.h>
 #include <asm/checksum.h>
 /* not coded yet?? EXPORT_SYMBOL(csum_ipv6_magic); */

--UlVJffcvxoiEqYs2--

