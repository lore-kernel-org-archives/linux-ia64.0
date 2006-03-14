From: "Jun'ichi Nomura" <j-nomura@ce.jp.nec.com>
Date: Tue, 14 Mar 2006 21:01:02 +0000
Subject: [PATCH] (-mm) drivers/pci/msi: explicit declaration of msi_register
Message-Id: <44172F0E.6070708@ce.jp.nec.com>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="------------000905020003000705030609"
List-Id: <linux-ia64.vger.kernel.org>
To: linux-kernel@vger.kernel.org
Cc: linux-ia64@vger.kernel.org, Greg KH <gregkh@suse.de>, maule@sgi.com, Andrew Morton <akpm@osdl.org>

This is a multi-part message in MIME format.
--------------000905020003000705030609
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit

Hello,

In 2.6.16-rc6-mm1, I've seen tons of compiler warnings on ia64:

include2/asm/msi.h: In function `ia64_msi_init':
include2/asm/msi.h:23: warning: implicit declaration of function `msi_register'
In file included from include2/asm/machvec.h:408,
                 from include2/asm/io.h:70,
                 from include2/asm/smp.h:20,
                 from /build/rc6/source/include/linux/smp.h:22,

The problem is that msi_register() is used in ia64_msi_init()
without declaration.
Since ia64_msi_init() is a part of machine vector, most of files
hit this warning and may hide other important messages.

Other than ia64, i386 and x86_64 have similar msi.h.
But they are not affected since include/asm/msi.h isn't
included without drivers/pci/pci.h where msi_register() is
declared.

The attached patch fixes this specific problem.
Proper fix might be moving the declaration in common header
but including something from machvec.h causes a lot of other
problems, so it would be nice if someone have better idea on this.

Thanks,
-- 
Jun'ichi Nomura, NEC Solutions (America), Inc.

--------------000905020003000705030609
Content-Type: text/x-patch;
 name="explicit-declaration-of-msi-register.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="explicit-declaration-of-msi-register.patch"

Declare msi_register() in msi.h.

The patch is especially necessary for ia64 on which most of files
emit compiler warnings like below:
  include2/asm/msi.h: In function `ia64_msi_init':
  include2/asm/msi.h:23: warning: implicit declaration of function `msi_register'
  In file included from include2/asm/machvec.h:408,
                 from include2/asm/io.h:70,
                 from include2/asm/smp.h:20,
                 from /build/rc6/source/include/linux/smp.h:22,

Signed-off-by: Jun'ichi Nomura <j-nomura@ce.jp.nec.com>

--- linux-2.6.16-rc6-mm1.orig/include/asm-ia64/msi.h	2006-03-14 13:54:11.000000000 -0500
+++ linux-2.6.16-rc6-mm1/include/asm-ia64/msi.h	2006-03-14 14:05:26.000000000 -0500
@@ -15,6 +15,7 @@ static inline void set_intr_gate (int nr
 #define MSI_TARGET_CPU_SHIFT	4
 
 extern struct msi_ops msi_apic_ops;
+extern int msi_register(struct msi_ops *);
 
 /* default ia64 msi init routine */
 static inline int ia64_msi_init(void)

--------------000905020003000705030609--
