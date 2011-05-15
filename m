From: =?UTF-8?B?TsOpbWV0aCBNw6FydG9u?= <nm127@freemail.hu>
Date: Sun, 15 May 2011 19:09:33 +0000
Subject: [PATCH] x86 pci acpi: rename struct pci_root_info
Message-Id: <4DD024ED.9000509@freemail.hu>
List-Id: <linux-ia64.vger.kernel.org>
References: <4DCEB5BB.1080202@freemail.hu> <4DCEC4EB.2050107@zytor.com>
In-Reply-To: <4DCEC4EB.2050107@zytor.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
To: "H. Peter Anvin" <hpa@zytor.com>
Cc: Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, x86@kernel.org, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, linux-ia64@vger.kernel.org, Julia Lawall <julia@diku.dk>, LKML <linux-kernel@vger.kernel.org>

From: Márton Németh <nm127@freemail.hu>

Rename struct pci_root_info to struct acpi_pci_root_info in
arch/x86/pci/acpi.c because there is already a struct
pci_root_info declared in arch/x86/pci/bus_numa.h . They both
belnog to x86 architecture and the two declarations differ,
so after rename each will have a unique name.

Signed-off-by: Márton Németh <nm127@freemail.hu>
---
--- linux-2.6.39-rc7/arch/x86/pci/acpi.c.orig	2011-05-10 04:33:54.000000000 +0200
+++ linux-2.6.39-rc7/arch/x86/pci/acpi.c	2011-05-15 17:02:52.000000000 +0200
@@ -7,7 +7,7 @@
 #include <asm/numa.h>
 #include <asm/pci_x86.h>

-struct pci_root_info {
+struct acpi_pci_root_info {
 	struct acpi_device *bridge;
 	char *name;
 	unsigned int res_num;
@@ -120,7 +120,7 @@ resource_to_addr(struct acpi_resource *r
 static acpi_status
 count_resource(struct acpi_resource *acpi_res, void *data)
 {
-	struct pci_root_info *info = data;
+	struct acpi_pci_root_info *info = data;
 	struct acpi_resource_address64 addr;
 	acpi_status status;

@@ -133,7 +133,7 @@ count_resource(struct acpi_resource *acp
 static acpi_status
 setup_resource(struct acpi_resource *acpi_res, void *data)
 {
-	struct pci_root_info *info = data;
+	struct acpi_pci_root_info *info = data;
 	struct resource *res;
 	struct acpi_resource_address64 addr;
 	acpi_status status;
@@ -188,7 +188,7 @@ static bool resource_contains(struct res
 	return false;
 }

-static void coalesce_windows(struct pci_root_info *info, int type)
+static void coalesce_windows(struct acpi_pci_root_info *info, int type)
 {
 	int i, j;
 	struct resource *res1, *res2;
@@ -223,7 +223,7 @@ static void coalesce_windows(struct pci_
 	}
 }

-static void add_resources(struct pci_root_info *info)
+static void add_resources(struct acpi_pci_root_info *info)
 {
 	int i;
 	struct resource *res, *root, *conflict;
@@ -259,7 +259,7 @@ static void
 get_current_resources(struct acpi_device *device, int busnum,
 			int domain, struct pci_bus *bus)
 {
-	struct pci_root_info info;
+	struct acpi_pci_root_info info;
 	size_t size;

 	if (pci_use_crs)
