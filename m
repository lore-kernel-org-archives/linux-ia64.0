From: "Luck, Tony" <tony.luck@intel.com>
Date: Wed, 01 Sep 2004 16:19:35 +0000
Subject: ia64 2.6.8 patch
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F01F09A76@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

David Mosberger gently reminded me:
>A tiger4 owner asked me why there isn't an ia64-specific patch for
>2.6.8.1 yet.  Are you planning to put one out shortly?

I've put linux-2.6.8-ia64-040901.diff.gz in the usual place
on kernel.org ... this is a patch against Linus 2.6.8, but
includes the 2.6.8 -> 2.6.8.1 generic patches as well as all
the pieces that I put into my linux-ia64-release-2.6.8.1 tree
(which turns out to be more than I really should have, many
of the pieces should just have gone to the release-2.6.9 tree).

The only piece anyone really *needs* to build 2.6.8 or 2.6.8.1
on ia64 is the one line addition to include/asm-ia64/acpi.h

 #define acpi_disabled 0        /* ACPI always enabled on IA64 */
+#define acpi_noirq 0   /* ACPI always enabled on IA64 */
 #define acpi_pci_disabled 0 /* ACPI PCI always enabled on IA64 */

-Tony
