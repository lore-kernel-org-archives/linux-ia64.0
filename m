From: Daniel Kiper <daniel.kiper@oracle.com>
Date: Mon, 30 Jun 2014 17:52:55 +0000
Subject: [PATCH v7 01/10] arch/ia64: Define early_memunmap()
Message-Id: <1404150784-27921-2-git-send-email-daniel.kiper@oracle.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1404150784-27921-1-git-send-email-daniel.kiper@oracle.com>
In-Reply-To: <1404150784-27921-1-git-send-email-daniel.kiper@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-efi@vger.kernel.org, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, x86@kernel.org, xen-devel@lists.xenproject.org
Cc: andrew.cooper3@citrix.com, boris.ostrovsky@oracle.com, david.vrabel@citrix.com, eshelton@pobox.com, fenghua.yu@intel.com, hpa@zytor.com, ian.campbell@citrix.com, jbeulich@suse.com, jeremy@goop.org, konrad.wilk@oracle.com, matt.fleming@intel.com, mingo@redhat.com, mjg59@srcf.ucam.org, stefano.stabellini@eu.citrix.com, tglx@linutronix.de, tony.luck@intel.com

This is odd to use early_iounmap() function do tear down mapping
created by early_memremap() function, even if it works right now,
because they belong to different set of functions. The former is
I/O related function and the later is memory related. So, create
early_memunmap() macro which in real is early_iounmap(). This
thing will help to not confuse code readers longer by mixing
functions from different classes.

EFI patches following this patch uses that functionality.

Signed-off-by: Daniel Kiper <daniel.kiper@oracle.com>
---
 arch/ia64/include/asm/io.h |    1 +
 1 file changed, 1 insertion(+)

diff --git a/arch/ia64/include/asm/io.h b/arch/ia64/include/asm/io.h
index 0d2bcb3..bee0acd 100644
--- a/arch/ia64/include/asm/io.h
+++ b/arch/ia64/include/asm/io.h
@@ -426,6 +426,7 @@ extern void iounmap (volatile void __iomem *addr);
 extern void __iomem * early_ioremap (unsigned long phys_addr, unsigned long size);
 #define early_memremap(phys_addr, size)        early_ioremap(phys_addr, size)
 extern void early_iounmap (volatile void __iomem *addr, unsigned long size);
+#define early_memunmap(addr, size)             early_iounmap(addr, size)
 static inline void __iomem * ioremap_cache (unsigned long phys_addr, unsigned long size)
 {
 	return ioremap(phys_addr, size);
-- 
1.7.10.4

