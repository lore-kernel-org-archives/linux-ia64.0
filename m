From: Bjorn Helgaas <bhelgaas@google.com>
Date: Wed, 29 Jan 2014 18:19:10 +0000
Subject: [PATCH 14/17] ACPI / numa: Fix acpi_get_node() prototype
Message-Id: <20140129181910.15476.66581.stgit@bhelgaas-glaptop.roam.corp.google.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20140129174106.15476.7075.stgit@bhelgaas-glaptop.roam.corp.google.com>
In-Reply-To: <20140129174106.15476.7075.stgit@bhelgaas-glaptop.roam.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-pci@vger.kernel.org
Cc: linux-acpi@vger.kernel.org, x86@kernel.org, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

acpi_get_node() takes an acpi_handle, not an "acpi_handle *".  This
fixes the prototype and the definitions.

Signed-off-by: Bjorn Helgaas <bhelgaas@google.com>
---
 drivers/acpi/numa.c  |    2 +-
 include/linux/acpi.h |    4 ++--
 2 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/acpi/numa.c b/drivers/acpi/numa.c
index 9e6816ef280a..dab7dac6b1a8 100644
--- a/drivers/acpi/numa.c
+++ b/drivers/acpi/numa.c
@@ -331,7 +331,7 @@ int acpi_get_pxm(acpi_handle h)
 	return -1;
 }
 
-int acpi_get_node(acpi_handle *handle)
+int acpi_get_node(acpi_handle handle)
 {
 	int pxm, node = NUMA_NO_NODE;
 
diff --git a/include/linux/acpi.h b/include/linux/acpi.h
index 1151a1dcfe41..17bee650a0cb 100644
--- a/include/linux/acpi.h
+++ b/include/linux/acpi.h
@@ -260,13 +260,13 @@ extern void acpi_osi_setup(char *str);
 
 #ifdef CONFIG_ACPI_NUMA
 int acpi_get_pxm(acpi_handle handle);
-int acpi_get_node(acpi_handle *handle);
+int acpi_get_node(acpi_handle handle);
 #else
 static inline int acpi_get_pxm(acpi_handle handle)
 {
 	return 0;
 }
-static inline int acpi_get_node(acpi_handle *handle)
+static inline int acpi_get_node(acpi_handle handle)
 {
 	return 0;
 }

