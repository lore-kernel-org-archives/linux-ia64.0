From: Bjorn Helgaas <bhelgaas@google.com>
Date: Wed, 29 Jan 2014 18:19:32 +0000
Subject: [PATCH 17/17] ACPI / numa: Use __weak, not the gcc-specific version
Message-Id: <20140129181932.15476.8351.stgit@bhelgaas-glaptop.roam.corp.google.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20140129174106.15476.7075.stgit@bhelgaas-glaptop.roam.corp.google.com>
In-Reply-To: <20140129174106.15476.7075.stgit@bhelgaas-glaptop.roam.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-pci@vger.kernel.org
Cc: linux-acpi@vger.kernel.org, x86@kernel.org, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

Use "__weak" instead of the gcc-specific "__attribute__ ((weak))".

Signed-off-by: Bjorn Helgaas <bhelgaas@google.com>
---
 drivers/acpi/numa.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/acpi/numa.c b/drivers/acpi/numa.c
index 359a43bdd948..24b5476449a1 100644
--- a/drivers/acpi/numa.c
+++ b/drivers/acpi/numa.c
@@ -193,7 +193,7 @@ static int __init acpi_parse_slit(struct acpi_table_header *table)
 	return 0;
 }
 
-void __init __attribute__ ((weak))
+void __init __weak
 acpi_numa_x2apic_affinity_init(struct acpi_srat_x2apic_cpu_affinity *pa)
 {
 	printk(KERN_WARNING PREFIX

