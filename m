From: "Jun'ichi Nomura" <j-nomura@ce.jp.nec.com>
Date: Thu, 16 Mar 2006 15:19:44 +0000
Subject: Re: [PATCH] (-mm) drivers/pci/msi: explicit declaration of msi_register
Message-Id: <44198210.6090109@ce.jp.nec.com>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="------------050904080408040707040806"
List-Id: <linux-ia64.vger.kernel.org>
References: <44172F0E.6070708@ce.jp.nec.com> <20060314134535.72eb7243.akpm@osdl.org> <44176502.9050109@ce.jp.nec.com> <20060315235544.GA6504@suse.de>
In-Reply-To: <20060315235544.GA6504@suse.de>
To: Greg KH <gregkh@suse.de>, Andrew Morton <akpm@osdl.org>, maule@sgi.com
Cc: linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, shaohua.li@intel.com

This is a multi-part message in MIME format.
--------------050904080408040707040806
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Greg KH wrote:
> No, we don't need a linux/msi.h, these are core pci things that no one
> else should care about.  The other arches handle this just fine, let's
> not mess everything up just because ia64 can't get it right :)

Hmm, it sounds asm/msi.h shouldn't be included from common headers. :<
I think the attached patch might be better. How about this?

Default msi_arch_init() looks sufficient for most ia64 platforms
except for SGI SN2, which seems to need its special version.
gregkh-pci-msi-vector-targeting-abstractions.patch used machvec
to switch the functions between platforms.
For that, it included asm/msi.h from asm/machvec.h and
caused the warnings flood.
The attached patch separates machvec function and the original
inline function. So that we don't need to include asm/msi.h from
common headers.


There is another problem that CONFIG_IA64_GENERIC still doesn't
build due to error in SGI SN specific code.
It needs additional fix.

Thanks,
-- 
Jun'ichi Nomura, NEC Solutions (America), Inc.

--------------050904080408040707040806
Content-Type: text/x-patch;
 name="ia64-machvec-based-msi-init.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="ia64-machvec-based-msi-init.patch"

asm/msi.h is a private header for core pci code.
It should not be included from common header.

Signed-off-by: Jun'ichi Nomura <j-nomura@ce.jp.nec.com>

--- linux-2.6.16-rc6-mm1.orig/include/asm-ia64/msi.h	2006-03-14 13:54:11.000000000 -0500
+++ linux-2.6.16-rc6-mm1/include/asm-ia64/msi.h	2006-03-16 01:36:44.000000000 -0500
@@ -17,12 +17,12 @@ static inline void set_intr_gate (int nr
 extern struct msi_ops msi_apic_ops;
 
 /* default ia64 msi init routine */
-static inline int ia64_msi_init(void)
+static inline int msi_arch_init(void)
 {
+	if (platform_msi_init)
+		return platform_msi_init();
 	msi_register(&msi_apic_ops);
 	return 0;
 }
 
-#define msi_arch_init		platform_msi_init	/* in asm/machvec.h */
-
 #endif /* ASM_MSI_H */
--- linux-2.6.16-rc6-mm1.orig/include/asm-ia64/machvec.h	2006-03-16 01:22:49.000000000 -0500
+++ linux-2.6.16-rc6-mm1/include/asm-ia64/machvec.h	2006-03-16 01:40:34.000000000 -0500
@@ -404,12 +404,7 @@ extern ia64_mv_dma_supported		swiotlb_dm
 # define platform_migrate machvec_noop_task
 #endif
 #ifndef platform_msi_init
-#ifdef CONFIG_PCI_MSI
-#include <asm/msi.h>		/* pull in ia64_msi_init() */
-# define platform_msi_init	ia64_msi_init
-#else
 # define platform_msi_init	NULL
-#endif /* CONFIG_PCI_MSI */
 #endif
 
 #endif /* _ASM_IA64_MACHVEC_H */

--------------050904080408040707040806--
