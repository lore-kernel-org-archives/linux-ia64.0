From: Alex Williamson <alex.williamson@hp.com>
Date: Thu, 23 Jun 2005 21:33:28 +0000
Subject: Re: [PATCH] pcibus_to_node implementation for IA64
Message-Id: <1119562408.5963.24.camel@tdi>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.62.0506231400360.13123@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.62.0506231400360.13123@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, 2005-06-23 at 14:19 -0700, Christoph Lameter wrote:
> On Thu, 23 Jun 2005, Alex Williamson wrote:
> 
> >    This will work, but there's no reason to hide this in the platform
> > specific code.  The PCI root bridges are in ACPI namespace, a
> > pxm_to_node() lookup should be done there when the buses are discovered.
> > Then it would work on HP and DIG boxes.  Thanks,
> 
> Could you do that? We only provide minimal ACPI support which does not 
> include pci. For our needs this will not work.

   I believe the below (untested) will work.  I'll try to test it on a
box.  Thanks,

	Alex

-- 
Alex Williamson                             HP Linux & Open Source Lab


diff --git a/arch/ia64/pci/pci.c b/arch/ia64/pci/pci.c
--- a/arch/ia64/pci/pci.c
+++ b/arch/ia64/pci/pci.c
@@ -306,6 +306,7 @@ pci_acpi_scan_root(struct acpi_device *d
 	unsigned int windows = 0;
 	struct pci_bus *pbus;
 	char *name;
+	int pxm;
 
 	controller = alloc_pci_controller(domain);
 	if (!controller)
@@ -313,6 +314,10 @@ pci_acpi_scan_root(struct acpi_device *d
 
 	controller->acpi_handle = device->handle;
 
+	pxm = acpi_get_pxm(controller->acpi_handle);
+	if (pxm >= 0)
+		controller->node = pxm_to_nid_map[pxm];
+
 	acpi_walk_resources(device->handle, METHOD_NAME__CRS, count_window,
 			&windows);
 	controller->window = kmalloc(sizeof(*controller->window) * windows,


