From: Yinghai Lu <yinghai@kernel.org>
Date: Wed, 19 Sep 2012 17:49:01 +0000
Subject: [PATCH] PCI, ia64: clear initial value for root info resources
Message-Id: <1348076941-410-2-git-send-email-yinghai@kernel.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <CAE9FiQW0PpBU0N9VzJyNKK9PvaUwokCYeB6w_j4mcN9EV0geLQ@mail.gmail.com>
 <1348076941-410-1-git-send-email-yinghai@kernel.org>
In-Reply-To: <1348076941-410-1-git-send-email-yinghai@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Bjorn Helgaas <bhelgaas@google.com>
Cc: linux-pci@vger.kernel.org, linux-kernel@vger.kernel.org, Yinghai Lu <yinghai@kernel.org>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, linux-ia64@vger.kernel.org

after
	PCI, ia64: clear initial value for root info resources

change ia64 code accordingly, because later ia64 will support root bus removal too.

Signed-off-by: Yinghai Lu <yinghai@kernel.org>
Cc: Tony Luck <tony.luck@intel.com>
Cc: Fenghua Yu <fenghua.yu@intel.com>
Cc: linux-ia64@vger.kernel.org

---
 arch/ia64/pci/pci.c |    3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

Index: linux-2.6/arch/ia64/pci/pci.c
=================================--- linux-2.6.orig/arch/ia64/pci/pci.c
+++ linux-2.6/arch/ia64/pci/pci.c
@@ -295,7 +295,6 @@ static __devinit acpi_status add_window(
 	window->resource.flags = flags;
 	window->resource.start = addr.minimum + offset;
 	window->resource.end = window->resource.start + addr.address_length - 1;
-	window->resource.child = NULL;
 	window->offset = offset;
 
 	if (insert_resource(root, &window->resource)) {
@@ -357,7 +356,7 @@ pci_acpi_scan_root(struct acpi_pci_root
 			&windows);
 	if (windows) {
 		controller->window -			kmalloc_node(sizeof(*controller->window) * windows,
+			kzalloc_node(sizeof(*controller->window) * windows,
 				     GFP_KERNEL, controller->node);
 		if (!controller->window)
 			goto out2;
