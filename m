From: Rajesh Shah <rajesh.shah@intel.com>
Date: Fri, 18 Mar 2005 22:14:15 +0000
Subject: [patch 08/12] Remove hot-plugged devices that could not be allocated resources
Message-Id: <20050318141415.H1145@unix-os.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20050318133856.A878@unix-os.sc.intel.com>
In-Reply-To: <20050318133856.A878@unix-os.sc.intel.com>; from rajesh.shah@intel.com on Fri, Mar 18, 2005 at 01:38:57PM -0800
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: gregkh@suse.de, tony.luck@intel.com, len.brown@intel.com
Cc: linux-pci@atrey.karlin.mff.cuni.cz, linux-kernel@vger.kernel.org, pcihpd-discuss@lists.sourceforge.net, linux-ia64@vger.kernel.org, acpi-devel@lists.sourceforge.net

When hot-plugging an I/O hierarchy that contains many bridges
and leaf devices, it's possible that there are not enough 
resources to start all the device present. If we fail to assign
a resource, clear the corresponding value in the pci_dev structure,
so other code can take corrective action.

Signed-off-by: Rajesh Shah <rajesh.shah@intel.com>
---

 linux-2.6.11-mm4-iohp-rshah1/drivers/pci/setup-bus.c |    5 ++++-
 1 files changed, 4 insertions(+), 1 deletion(-)

diff -puN drivers/pci/setup-bus.c~discard_no_resource_devs drivers/pci/setup-bus.c
--- linux-2.6.11-mm4-iohp/drivers/pci/setup-bus.c~discard_no_resource_devs	2005-03-16 13:07:26.557944717 -0800
+++ linux-2.6.11-mm4-iohp-rshah1/drivers/pci/setup-bus.c	2005-03-16 13:07:26.666343153 -0800
@@ -72,7 +72,10 @@ pbus_assign_resources_sorted(struct pci_
 	for (list = head.next; list;) {
 		res = list->res;
 		idx = res - &list->dev->resource[0];
-		pci_assign_resource(list->dev, idx);
+		if (pci_assign_resource(list->dev, idx)) {
+			res->start = 0;
+			res->flags = 0;
+		}
 		tmp = list;
 		list = list->next;
 		kfree(tmp);
_
