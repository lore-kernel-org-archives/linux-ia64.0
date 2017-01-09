From: Paul Gortmaker <paul.gortmaker@windriver.com>
Date: Mon, 09 Jan 2017 00:19:07 +0000
Subject: [PATCH] nfc: don't be making arch specific unaligned decisions at driver level.
Message-Id: <20170109001907.101949-1-paul.gortmaker@windriver.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
To: linux-kernel@vger.kernel.org
Cc: Paul Gortmaker <paul.gortmaker@windriver.com>, Lauro Ramos Venancio <lauro.venancio@openbossa.org>, Aloisio Almeida Jr <aloisio.almeida@openbossa.org>, Samuel Ortiz <sameo@linux.intel.com>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, linux-ia64@vger.kernel.org, linux-wireless@vger.kernel.org

Currently ia64 fails building allmodconfig with variations of:

   In file included from drivers/nfc/nxp-nci/i2c.c:39:0:
   ./include/linux/unaligned/access_ok.h:62:29: error: redefinition of ‘put_unaligned_be64’
    static __always_inline void put_unaligned_be64(u64 val, void *p)
                                ^~~~~~~~~~~~~~~~~~
   In file included from ./arch/ia64/include/asm/unaligned.h:5:0,
                    from ./arch/ia64/include/asm/io.h:22,
                    from ./arch/ia64/include/asm/smp.h:20,
                    from ./include/linux/smp.h:59,
                    from ./include/linux/topology.h:33,
                    from ./include/linux/gfp.h:8,
                    from ./include/linux/slab.h:14,
                    from ./include/linux/resource_ext.h:19,
                    from ./include/linux/acpi.h:26,
                    from drivers/nfc/nxp-nci/i2c.c:28:
   ./include/linux/unaligned/be_byteshift.h:65:20: note: previous definition of ‘put_unaligned_be64’ was here
    static inline void put_unaligned_be64(u64 val, void *p)
                       ^~~~~~~~~~~~~~~~~~
   scripts/Makefile.build:293: recipe for target 'drivers/nfc/nxp-nci/i2c.o' failed

The easiest explanation for this is to look at the non-arch users in
the following output:

   linux$git grep include.*access_ok.h
   arch/arm64/crypto/crc32-arm64.c:#include <linux/unaligned/access_ok.h>
   arch/cris/include/asm/unaligned.h:#include <linux/unaligned/access_ok.h>
   arch/m68k/include/asm/unaligned.h:#include <linux/unaligned/access_ok.h>
   arch/mn10300/include/asm/unaligned.h:#include <linux/unaligned/access_ok.h>
   arch/powerpc/include/asm/unaligned.h:#include <linux/unaligned/access_ok.h>
   arch/s390/include/asm/unaligned.h:#include <linux/unaligned/access_ok.h>
   arch/x86/include/asm/unaligned.h:#include <linux/unaligned/access_ok.h>
   drivers/nfc/nfcmrvl/fw_dnld.c:#include <linux/unaligned/access_ok.h>
   drivers/nfc/nxp-nci/firmware.c:#include <linux/unaligned/access_ok.h>
   drivers/nfc/nxp-nci/i2c.c:#include <linux/unaligned/access_ok.h>
   include/asm-generic/unaligned.h:# include <linux/unaligned/access_ok.h>

Note that nfc is essentially the only non-arch user in the above.
When it forces use of access_ok.h, it will break any arch that has
already selected be_byteshift.h (or other conflicting implementations)
at the arch level.

The decision of what variant for unaligned access to use needs to be
left to the arch level and not used at the driver level.  Delete the
errant includes, as the right ones will be pulled in at the arch
level, giving us just the one definition that is needed.

See commit 064106a91be5 ("kernel: add common infrastructure for
unaligned access") as a reference.

Cc: Lauro Ramos Venancio <lauro.venancio@openbossa.org>
Cc: Aloisio Almeida Jr <aloisio.almeida@openbossa.org>
Cc: Samuel Ortiz <sameo@linux.intel.com>
Cc: Tony Luck <tony.luck@intel.com>
Cc: Fenghua Yu <fenghua.yu@intel.com>
Cc: linux-ia64@vger.kernel.org
Cc: linux-wireless@vger.kernel.org
Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>

diff --git a/drivers/nfc/nfcmrvl/fw_dnld.c b/drivers/nfc/nfcmrvl/fw_dnld.c
index f8dcdf4b24f6..32144d66ba88 100644
--- a/drivers/nfc/nfcmrvl/fw_dnld.c
+++ b/drivers/nfc/nfcmrvl/fw_dnld.c
@@ -17,7 +17,6 @@
  */
 
 #include <linux/module.h>
-#include <linux/unaligned/access_ok.h>
 #include <linux/firmware.h>
 #include <linux/nfc.h>
 #include <net/nfc/nci.h>
diff --git a/drivers/nfc/nxp-nci/firmware.c b/drivers/nfc/nxp-nci/firmware.c
index 5291797324ba..f2bd651fc60d 100644
--- a/drivers/nfc/nxp-nci/firmware.c
+++ b/drivers/nfc/nxp-nci/firmware.c
@@ -24,7 +24,6 @@
 #include <linux/completion.h>
 #include <linux/firmware.h>
 #include <linux/nfc.h>
-#include <linux/unaligned/access_ok.h>
 
 #include "nxp-nci.h"
 
diff --git a/drivers/nfc/nxp-nci/i2c.c b/drivers/nfc/nxp-nci/i2c.c
index 36099e557730..d25f6257458e 100644
--- a/drivers/nfc/nxp-nci/i2c.c
+++ b/drivers/nfc/nxp-nci/i2c.c
@@ -36,7 +36,6 @@
 #include <linux/of_gpio.h>
 #include <linux/of_irq.h>
 #include <linux/platform_data/nxp-nci.h>
-#include <linux/unaligned/access_ok.h>
 
 #include <net/nfc/nfc.h>
 
-- 
2.11.0

