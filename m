From: Bjorn Helgaas <bhelgaas@google.com>
Date: Wed, 29 Jan 2014 18:19:18 +0000
Subject: [PATCH 15/17] ACPI / numa: Simplify acpi_get_node() style
Message-Id: <20140129181918.15476.38407.stgit@bhelgaas-glaptop.roam.corp.google.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20140129174106.15476.7075.stgit@bhelgaas-glaptop.roam.corp.google.com>
In-Reply-To: <20140129174106.15476.7075.stgit@bhelgaas-glaptop.roam.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-pci@vger.kernel.org
Cc: linux-acpi@vger.kernel.org, x86@kernel.org, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

Simplify control flow by removing local variable initialization and
returning a constant as soon as possible.  No functional change.

Signed-off-by: Bjorn Helgaas <bhelgaas@google.com>
---
 drivers/acpi/numa.c |    8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/acpi/numa.c b/drivers/acpi/numa.c
index dab7dac6b1a8..a7e779bfa2f6 100644
--- a/drivers/acpi/numa.c
+++ b/drivers/acpi/numa.c
@@ -333,12 +333,12 @@ int acpi_get_pxm(acpi_handle h)
 
 int acpi_get_node(acpi_handle handle)
 {
-	int pxm, node = NUMA_NO_NODE;
+	int pxm;
 
 	pxm = acpi_get_pxm(handle);
-	if (pxm >= 0 && pxm < MAX_PXM_DOMAINS)
-		node = acpi_map_pxm_to_node(pxm);
+	if (pxm < 0 || pxm >= MAX_PXM_DOMAINS)
+		return NUMA_NO_NODE;
 
-	return node;
+	return acpi_map_pxm_to_node(pxm);
 }
 EXPORT_SYMBOL(acpi_get_node);

