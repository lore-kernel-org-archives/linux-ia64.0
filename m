From: Matthew Wilcox <matthew@wil.cx>
Date: Tue, 24 Oct 2006 21:47:24 +0000
Subject: Re: Ordering between PCI config space writes and MMIO reads?
Message-Id: <20061024214724.GS25210@parisc-linux.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <adafyddcysw.fsf@cisco.com> <20061024192210.GE2043@havoc.gtf.org>
In-Reply-To: <20061024192210.GE2043@havoc.gtf.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Jeff Garzik <jeff@garzik.org>
Cc: Roland Dreier <rdreier@cisco.com>, linux-pci@atrey.karlin.mff.cuni.cz, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, openib-general@openib.org, John Partridge <johnip@sgi.com>

On Tue, Oct 24, 2006 at 03:22:10PM -0400, Jeff Garzik wrote:
> The PCI config APIs have traditionally enforced very strong ordering.
> Heck, the PCI config APIs often take a spinlock on each read or write;
> so they are definitely not intended to be as fast as MMIO.

s/often/always/.  It's implemented in drivers/pci/access.c.

I think the right way to fix this is to ensure mmio write ordering in
the pci_write_config_*() implementations.  Like this.

Signed-off-by: Matthew Wilcox <matthew@wil.cx>

diff --git a/drivers/pci/access.c b/drivers/pci/access.c
index ea16805..c80f1ba 100644
--- a/drivers/pci/access.c
+++ b/drivers/pci/access.c
@@ -1,6 +1,6 @@
 #include <linux/pci.h>
 #include <linux/module.h>
-#include <linux/ioport.h>
+#include <linux/io.h>
 
 #include "pci.h"
 
@@ -45,6 +45,7 @@ int pci_bus_write_config_##size \
 	if (PCI_##size##_BAD) return PCIBIOS_BAD_REGISTER_NUMBER;	\
 	spin_lock_irqsave(&pci_lock, flags);				\
 	res = bus->ops->write(bus, devfn, pos, len, value);		\
+	mmiowb();							\
 	spin_unlock_irqrestore(&pci_lock, flags);			\
 	return res;							\
 }
@@ -102,6 +103,7 @@ int pci_user_write_config_##size					\
 	if (likely(!dev->block_ucfg_access))				\
 		ret = dev->bus->ops->write(dev->bus, dev->devfn,	\
 					pos, sizeof(type), val);	\
+	mmiowb();							\
 	spin_unlock_irqrestore(&pci_lock, flags);			\
 	return ret;							\
 }
