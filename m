From: Rajesh Shah <rajesh.shah@intel.com>
Date: Thu, 03 Feb 2005 19:31:58 +0000
Subject: Re: [Pcihpd-discuss] [PATCH] Convert acpiphp to use generic resource code
Message-Id: <20050203113158.A22968@unix-os.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20050119183853.C12618@unix-os.sc.intel.com>
In-Reply-To: <20050119183853.C12618@unix-os.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, Jan 19, 2005 at 06:51:20PM +0000, Matthew Wilcox wrote:
> 
> This patch converts acpiphp to use the generic PCI resource assignment
> code.  It's quite large, but most of it is deleting the acpiphp_pci and
> acpiphp_res files.  It's tested on an hp Integrity rx8620 (which won't
> work without this patch).  Testers with other hardware welcomed.
> 
I needed the additional patch below to make it work on Tiger4
ia64 systems. I noticed that a similar patch was submitted before
(http://marc.theaimsgroup.com/?l=linux-ia64&m7962911317596&w=2)
but don't know why it was not picked up.

Signed-off-by: Rajesh Shah <rajesh.shah@intel.com>
---

 linux-2.6.11-rc1-mm2-t2-rshah1/arch/ia64/pci/pci.c |    1 +
 1 files changed, 1 insertion(+)

diff -puN arch/ia64/pci/pci.c~track_bridge_resources arch/ia64/pci/pci.c
--- linux-2.6.11-rc1-mm2-t2/arch/ia64/pci/pci.c~track_bridge_resources	2005-02-03 11:02:45.397329199 -0800
+++ linux-2.6.11-rc1-mm2-t2-rshah1/arch/ia64/pci/pci.c	2005-02-03 11:03:57.699086126 -0800
@@ -437,6 +437,7 @@ pcibios_fixup_bus (struct pci_bus *b)
 
 	list_for_each_entry(dev, &b->devices, bus_list)
 		pcibios_fixup_device_resources(dev);
+	pci_read_bridge_bases(b);
 
 	return;
 }
_
