From: Judith Lebzelter <judith@osdl.org>
Date: Fri, 06 Oct 2006 23:42:59 +0000
Subject: Compile errors for allmodconfig
Message-Id: <20061006234259.GB14909@shell0.pdx.osdl.net>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hello,

I am trying to get the alllmodconfig to build without errors for ia64 and it is not 
happening because of a few drivers:

WARNING: "check_signature" [drivers/scsi/fdomain.ko] undefined!
WARNING: "pci_get_legacy_ide_irq" [drivers/ide/pci/amd74xx.ko] undefined!
make[1]: [__modpost] Error 1 (ignored)

Should these compile on IA64, and if not can they be marked not IA64 in the Kconfig?

Thanks,
Judith Lebzelter
OSDL
