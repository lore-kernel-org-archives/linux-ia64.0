From: Martin Hicks <mort@wildopensource.com>
Date: Fri, 16 May 2003 19:21:01 +0000
Subject: Re: [Linux-ia64] runtime platform detection in GENERIC kernels
Message-Id: <marc-linux-ia64-105590723705909@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705791@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705791@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


On Wed, May 14, 2003 at 09:32:53AM -0600, Alex Williamson wrote:
> 
>    Why not just make a runtime strcmp to platform_name?  Then
> you could make a generic is_platform("sn2") type function/macro
> that everyone could use and you'd get rid of that nasty init
> function.  If you realy need to make such a check in a perfmance
> path, it should probably be a machvec.  Thanks,
> 


Here is the next iteration, based on your suggestions.  It also caches
the result of the first acpi_get_sysname() call, since this really
shouldn't change while the machine is running.

This is against the linux-ia64-2.5 bk tree.

It does include the sn2 platform detection in acpi_get_sysname(), which
may be duplicated in jbarnes' 2.5 patch.

mh

-- 
Wild Open Source Inc.                  mort@wildopensource.com


=== arch/ia64/kernel/acpi.c 1.40 vs edited ==--- 1.40/arch/ia64/kernel/acpi.c	Sat May 10 03:28:45 2003
+++ edited/arch/ia64/kernel/acpi.c	Fri May 16 17:23:28 2003
@@ -73,31 +73,43 @@
 	struct acpi20_table_rsdp *rsdp;
 	struct acpi_table_xsdt *xsdt;
 	struct acpi_table_header *hdr;
+	static char *sysname;
+
+	if (sysname)
+		return sysname;
 
 	rsdp_phys = acpi_find_rsdp();
 	if (!rsdp_phys) {
 		printk(KERN_ERR "ACPI 2.0 RSDP not found, default to \"dig\"\n");
-		return "dig";
+		sysname = "dig";
+		return sysname;
 	}
 
 	rsdp = (struct acpi20_table_rsdp *) __va(rsdp_phys);
 	if (strncmp(rsdp->signature, RSDP_SIG, sizeof(RSDP_SIG) - 1)) {
 		printk(KERN_ERR "ACPI 2.0 RSDP signature incorrect, default to \"dig\"\n");
-		return "dig";
+		sysname = "dig";
+		return sysname;
 	}
 
 	xsdt = (struct acpi_table_xsdt *) __va(rsdp->xsdt_address);
 	hdr = &xsdt->header;
 	if (strncmp(hdr->signature, XSDT_SIG, sizeof(XSDT_SIG) - 1)) {
 		printk(KERN_ERR "ACPI 2.0 XSDT signature incorrect, default to \"dig\"\n");
-		return "dig";
+		sysname = "dig";
+		return sysname;
 	}
 
 	if (!strcmp(hdr->oem_id, "HP")) {
-		return "hpzx1";
+		sysname = "hpzx1";
+		return sysname;
+	} else if (!strcmp(hdr->oem_id, "SGI")) {
+		sysname = "sn2";
+		return sysname;
 	}
 
-	return "dig";
+	sysname = "sn2";
+	return sysname;
 #else
 # if defined (CONFIG_IA64_HP_SIM)
 	return "hpsim";
=== include/asm-ia64/system.h 1.37 vs edited ==--- 1.37/include/asm-ia64/system.h	Thu May 15 05:45:02 2003
+++ edited/include/asm-ia64/system.h	Fri May 16 16:50:51 2003
@@ -29,6 +29,7 @@
 
 #include <linux/kernel.h>
 #include <linux/types.h>
+#include <linux/string.h>
 
 struct pci_vector_struct {
 	__u16 segment;	/* PCI Segment number */
@@ -275,6 +276,14 @@
 } while (0)
 #define finish_arch_switch(rq, prev)	spin_unlock_irq(&(prev)->switch_lock)
 #define task_running(rq, p) 		((rq)->curr = (p) || spin_is_locked(&(p)->switch_lock))
+
+extern const char * acpi_get_sysname(void);
+static inline int ia64_platform_is(const char *str) 
+{
+	if (!strcmp(str,acpi_get_sysname()))	
+		return 1;
+	return 0;
+}
 
 #endif /* __KERNEL__ */
 

