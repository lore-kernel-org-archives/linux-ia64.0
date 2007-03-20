From: John Keller <jpk@sgi.com>
Date: Tue, 20 Mar 2007 18:50:10 +0000
Subject: [PATCH] - Altix: ioremap vga_console_iobase
Message-Id: <20070320185010.4873.23012.sendpatchset@attica.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org
Cc: linux-kernel@vger.kernel.org, John Keller <jpk@sgi.com>

When booting an SN system without specifing a console
(i.e., no "console=" on boot line), the system will hang during
boot at the point where /sbin/init is run.

The problem is that vga_console_iobase is not converted to a
virtual address before storing in io_space[0].mmio_base.
The conversion was happening in sn_scan_pcdp(), but not in
setup_vga_console().

Signed-off-by: John Keller <jpk@sgi.com>
---

 arch/ia64/sn/kernel/setup.c |    6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)


Index: linux-2.6/arch/ia64/sn/kernel/setup.c
=================================--- linux-2.6.orig/arch/ia64/sn/kernel/setup.c	2007-03-16 15:23:54.743044272 -0500
+++ linux-2.6/arch/ia64/sn/kernel/setup.c	2007-03-20 13:22:38.837859262 -0500
@@ -348,8 +348,7 @@ sn_scan_pcdp(void)
 			continue;	/* not PCI interconnect */
 
 		if (if_pci.translation & PCDP_PCI_TRANS_IOPORT)
-			vga_console_iobase -				if_pci.ioport_tra | __IA64_UNCACHED_OFFSET;
+			vga_console_iobase = if_pci.ioport_tra;
 
 		if (if_pci.translation & PCDP_PCI_TRANS_MMIO)
 			vga_console_membase @@ -429,7 +428,8 @@ void __init sn_setup(char **cmdline_p)
 	 * 	bus containing the VGA console.
 	 */
 	if (vga_console_iobase) {
-		io_space[0].mmio_base = vga_console_iobase;
+		io_space[0].mmio_base +			(unsigned long) ioremap(vga_console_iobase, 0);
 		io_space[0].sparse = 0;
 	}
 
