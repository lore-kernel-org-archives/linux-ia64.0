From: Alex Williamson <alex.williamson@hp.com>
Date: Thu, 23 Jun 2005 22:53:04 +0000
Subject: Re: [PATCH] pcibus_to_node implementation for IA64
Message-Id: <1119567184.5963.35.camel@tdi>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.62.0506231400360.13123@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.62.0506231400360.13123@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, 2005-06-23 at 14:47 -0700, Christoph Lameter wrote:
> On Thu, 23 Jun 2005, Alex Williamson wrote:
> 
> >    I believe the below (untested) will work.  I'll try to test it on a
> > box.  Thanks,
> 
> Yes that is how other arches do it.

  Cool.  It works on an rx8620 here.  I forgot to wrap the generic setup
in a NUMA config.  The below chunks should replace the sba_iommu chunk
in the original patch.  Thanks,

	Alex

Signed-off-by: Alex Williamson <alex.williamson@hp.com>

diff --git a/arch/ia64/pci/pci.c b/arch/ia64/pci/pci.c
--- a/arch/ia64/pci/pci.c
+++ b/arch/ia64/pci/pci.c
@@ -288,6 +289,7 @@ pci_acpi_scan_root(struct acpi_device *d
 	unsigned int windows = 0;
 	struct pci_bus *pbus;
 	char *name;
+	int pxm;
 
 	controller = alloc_pci_controller(domain);
 	if (!controller)
@@ -295,6 +297,12 @@ pci_acpi_scan_root(struct acpi_device *d
 
 	controller->acpi_handle = device->handle;
 
+	pxm = acpi_get_pxm(controller->acpi_handle);
+#ifdef CONFIG_NUMA
+	if (pxm >= 0)
+		controller->node = pxm_to_nid_map[pxm];
+#endif
+
 	acpi_walk_resources(device->handle, METHOD_NAME__CRS, count_window,
 			&windows);
 	controller->window = kmalloc(sizeof(*controller->window) * windows,


