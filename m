From: jbarnes@sgi.com (Jesse Barnes)
Date: Mon, 08 Sep 2003 19:20:40 +0000
Subject: [PATCH] fix current usage in sn2 code
Message-Id: <marc-linux-ia64-106304956924447@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

For some reason, we had a structure field called 'current'.  This patch
fixes that.

Thanks,
Jesse


diff -Nru a/arch/ia64/sn/io/drivers/ioconfig_bus.c b/arch/ia64/sn/io/drivers/ioconfig_bus.c
--- a/arch/ia64/sn/io/drivers/ioconfig_bus.c	Mon Sep  8 12:12:36 2003
+++ b/arch/ia64/sn/io/drivers/ioconfig_bus.c	Mon Sep  8 12:12:36 2003
@@ -24,7 +24,7 @@
 #include <asm/sn/invent.h>
 #include <asm/sn/hcl.h>
 #include <asm/sn/labelcl.h>
-#include <asm//sn/sn_sal.h>
+#include <asm/sn/sn_sal.h>
 #include <asm/sn/addrs.h>
 #include <asm/sn/ioconfig_bus.h>
 
@@ -157,7 +157,7 @@
 	char *name;
 	char *temp;
 	char *next;
-	char *current;
+	char *curr;
 	char *line;
 	struct ascii_moduleid *moduleid;
 
@@ -166,10 +166,10 @@
 	name = kmalloc(125, GFP_KERNEL);
 	memset(name, 0, 125);
 	moduleid = table;
-	current = file_contents;
-	while (nextline(current, &next, line)){
+	curr = file_contents;
+	while (nextline(curr, &next, line)){
 
-		DBG("current 0x%lx next 0x%lx\n", current, next);
+		DBG("curr 0x%lx next 0x%lx\n", curr, next);
 
 		temp = line;
 		/*
@@ -182,7 +182,7 @@
 				break;
 
 		if (*temp = '\n') {
-			current = next;
+			curr = next;
 			memset(line, 0, 256);
 			continue;
 		}
@@ -191,7 +191,7 @@
 		 * Skip comment lines
 		 */
 		if (*temp = '#') {
-			current = next;
+			curr = next;
 			memset(line, 0, 256);
 			continue;
 		}
@@ -204,7 +204,7 @@
 		DBG("Found %s\n", name);
 		moduleid++;
 		free_entry++;
-		current = next;
+		curr = next;
 		memset(line, 0, 256);
 	}
 
diff -Nru a/arch/ia64/sn/io/machvec/pci_bus_cvlink.c b/arch/ia64/sn/io/machvec/pci_bus_cvlink.c
--- a/arch/ia64/sn/io/machvec/pci_bus_cvlink.c	Mon Sep  8 12:12:36 2003
+++ b/arch/ia64/sn/io/machvec/pci_bus_cvlink.c	Mon Sep  8 12:12:36 2003
@@ -544,7 +544,7 @@
 		pci_read_config_byte(device_dev, PCI_INTERRUPT_PIN,
 				     (unsigned char *)&lines);
 	 
-		irqpdaindr->current = device_dev;
+		irqpdaindr->curr = device_dev;
 		intr_handle = pciio_intr_alloc(device_vertex, NULL, lines, device_vertex);
 
 		irq = intr_handle->pi_irq;
diff -Nru a/arch/ia64/sn/io/sn2/ml_SN_intr.c b/arch/ia64/sn/io/sn2/ml_SN_intr.c
--- a/arch/ia64/sn/io/sn2/ml_SN_intr.c	Mon Sep  8 12:12:36 2003
+++ b/arch/ia64/sn/io/sn2/ml_SN_intr.c	Mon Sep  8 12:12:36 2003
@@ -174,8 +174,8 @@
 			min_shared = 256;
 			for (i=IA64_SN2_FIRST_DEVICE_VECTOR; i < IA64_SN2_LAST_DEVICE_VECTOR; i++) {
 				/* Share with the same device class */
-				if (irqpdaindr->current->vendor = irqpdaindr->device_dev[i]->vendor &&
-					irqpdaindr->current->device = irqpdaindr->device_dev[i]->device &&
+				if (irqpdaindr->curr->vendor = irqpdaindr->device_dev[i]->vendor &&
+					irqpdaindr->curr->device = irqpdaindr->device_dev[i]->device &&
 					irqpdaindr->share_count[i] < min_shared) {
 						min_shared = irqpdaindr->share_count[i];
 						bit = i;
diff -Nru a/include/asm-ia64/sn/nodepda.h b/include/asm-ia64/sn/nodepda.h
--- a/include/asm-ia64/sn/nodepda.h	Mon Sep  8 12:12:35 2003
+++ b/include/asm-ia64/sn/nodepda.h	Mon Sep  8 12:12:36 2003
@@ -87,7 +87,7 @@
 	char irq_flags[NR_IRQS];
 	struct pci_dev *device_dev[NR_IRQS];
 	char share_count[NR_IRQS];
-	struct pci_dev *current;
+	struct pci_dev *curr;
 };
 
 typedef struct irqpda_s irqpda_t;
