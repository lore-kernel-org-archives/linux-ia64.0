From: Kenji Kaneshige <kaneshige.kenji@jp.fujitsu.com>
Date: Tue, 22 May 2007 01:23:40 +0000
Subject: Re: [PATCH] fix kmalloc(0) in arch/ia64/pci/pci.c
Message-Id: <1179797021.3872.6.camel@kane-linux>
List-Id: <linux-ia64.vger.kernel.org>
References: <20070517110056.779944a2.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20070517110056.779944a2.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi,

Here is a patch to fix zero size kmalloc problem that was reported
by Hiroyuki Kamezawa.

Thanks,
Kenji Kaneshige

---
Hiroyuki Kamezawa reported the problem that pci_acpi_scan_root() of
ia64 might call kmalloc_node() with zero size. 

Currently ia64's pci_acpi_scan_root() assumes that _CRS method of root
bridge has at least one resource window. But, the root bridges that
has no resource window must be taken into account.

Signed-off-by: Kenji Kaneshige <kaneshige.kenji@jp.fujitsu.com>
---
 arch/ia64/pci/pci.c |   11 +++++++----
 1 files changed, 7 insertions(+), 4 deletions(-)

Index: linux-2.6.22-rc1/arch/ia64/pci/pci.c
=================================--- linux-2.6.22-rc1.orig/arch/ia64/pci/pci.c
+++ linux-2.6.22-rc1/arch/ia64/pci/pci.c
@@ -354,10 +354,13 @@ pci_acpi_scan_root(struct acpi_device *d
 
 	acpi_walk_resources(device->handle, METHOD_NAME__CRS, count_window,
 			&windows);
-	controller->window = kmalloc_node(sizeof(*controller->window) * windows,
-			GFP_KERNEL, controller->node);
-	if (!controller->window)
-		goto out2;
+	if (windows) {
+		controller->window +			kmalloc_node(sizeof(*controller->window) * windows,
+				     GFP_KERNEL, controller->node);
+		if (!controller->window)
+			goto out2;
+	}
 
 	name = kmalloc(16, GFP_KERNEL);
 	if (!name)


