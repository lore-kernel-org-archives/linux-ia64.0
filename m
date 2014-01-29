From: Bjorn Helgaas <bhelgaas@google.com>
Date: Wed, 29 Jan 2014 18:18:33 +0000
Subject: [PATCH 09/17] x86/PCI: Remove unnecessary list_empty(&pci_root_infos) check
Message-Id: <20140129181833.15476.93146.stgit@bhelgaas-glaptop.roam.corp.google.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20140129174106.15476.7075.stgit@bhelgaas-glaptop.roam.corp.google.com>
In-Reply-To: <20140129174106.15476.7075.stgit@bhelgaas-glaptop.roam.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-pci@vger.kernel.org
Cc: linux-acpi@vger.kernel.org, x86@kernel.org, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

list_for_each_entry() handles empty lists, so there's no need to check
whether the list is empty first.

Signed-off-by: Bjorn Helgaas <bhelgaas@google.com>
---
 arch/x86/pci/bus_numa.c |    3 ---
 1 file changed, 3 deletions(-)

diff --git a/arch/x86/pci/bus_numa.c b/arch/x86/pci/bus_numa.c
index 2e36a4469549..f3a2cfc14125 100644
--- a/arch/x86/pci/bus_numa.c
+++ b/arch/x86/pci/bus_numa.c
@@ -10,9 +10,6 @@ static struct pci_root_info *x86_find_pci_root_info(int bus)
 {
 	struct pci_root_info *info;
 
-	if (list_empty(&pci_root_infos))
-		return NULL;
-
 	list_for_each_entry(info, &pci_root_infos, list)
 		if (info->busn.start = bus)
 			return info;

