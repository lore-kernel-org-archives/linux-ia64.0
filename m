From: "H . J . Lu" <hjl@valinux.com>
Date: Sun, 10 Sep 2000 00:57:08 +0000
Subject: Re: [Linux-ia64] kernel update (relative to v2.4.0-test8)
Message-Id: <marc-linux-ia64-105590678205479@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205111@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205111@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Sat, Sep 09, 2000 at 05:39:26PM -0700, H . J . Lu wrote:
> On Sat, Sep 09, 2000 at 05:17:12PM -0700, David Mosberger wrote:
> > >>>>> On Sat, 9 Sep 2000 14:49:52 -0700, "H . J . Lu" <hjl@valinux.com> said:
> > 
> >   HJ> Yes, I did "make dep". What should include/asm-ia64/offsets.h
> >   HJ> look like? That may explain many things.
> > 
> > Well, it depends on your kernel configuration.  If you did a "make
> > dep", you should have the right values in there.
> > 
> > I'm not sure why the new kernel isn't working for you.  Nothing has
> > changed in the kernel that would explain an infinite stream of irq 0.
> > 
> 
> I am going through my build log. I found at least 2 problems:
> 
> 1. In inclide/asm-ia64/processor.h, there is
> 
> # define loops_per_sec()       loops_per_sec
> 
> It is bad if the versioned symbol is enabled.
> 
> 2. ACPI_RSDT_SIG is defined both as a string and an integer in
> 2 different header files. In include/linux/acpi.h
> 
> #define ACPI_RSDT_SIG  0x54445352 /* 'RSDT' */
> 
> In include/asm-ia64/acpi-ext.h
> 
> #define ACPI_RSDT_SIG "RSDT"
> 
> It is very confusing.
> 
> I am enclosing 2 patches. Please take a look.
> 

Opps. The patch for string missed one patch. Here is the new
string.patch.

H.J.
---
--- linux/arch/ia64/kernel/acpi.c.string	Sat Sep  9 17:54:02 2000
+++ linux/arch/ia64/kernel/acpi.c	Sat Sep  9 17:31:11 2000
@@ -226,14 +226,14 @@ acpi_parse(acpi_rsdp_t *rsdp)
 		return 0;
 	}
 
-	if (strncmp(rsdp->signature, ACPI_RSDP_SIG, ACPI_RSDP_SIG_LEN)) {
+	if (strncmp(rsdp->signature, ACPI_RSDP_SIG_STR, ACPI_RSDP_SIG_LEN)) {
 		printk("Uh-oh, ACPI RSDP signature incorrect!\n");
 		return 0;
 	}
 
 	rsdp->rsdt = __va(rsdp->rsdt);
 	rsdt = rsdp->rsdt;
-	if (strncmp(rsdt->header.signature, ACPI_RSDT_SIG, ACPI_RSDT_SIG_LEN)) {
+	if (strncmp(rsdt->header.signature, ACPI_RSDT_SIG_STR, ACPI_RSDT_SIG_LEN)) {
 		printk("Uh-oh, ACPI RDST signature incorrect!\n");
 		return 0;
 	}
@@ -250,7 +250,7 @@ acpi_parse(acpi_rsdp_t *rsdp)
 		hdrp = (acpi_desc_table_hdr_t *) __va(rsdt->entry_ptrs[i]);
 
 		/* Only interested int the MSAPIC table for now ... */
-		if (strncmp(hdrp->signature, ACPI_SAPIC_SIG, ACPI_SAPIC_SIG_LEN) != 0)
+		if (strncmp(hdrp->signature, ACPI_SAPIC_SIG_STR, ACPI_SAPIC_SIG_LEN) != 0)
 			continue;
 
 		acpi_parse_msapic((acpi_sapic_t *) hdrp);
--- linux/include/asm-ia64/acpi-ext.h.string	Sat Sep  9 17:27:38 2000
+++ linux/include/asm-ia64/acpi-ext.h	Sat Sep  9 17:28:12 2000
@@ -12,7 +12,7 @@
 
 #include <linux/types.h>
 
-#define ACPI_RSDP_SIG "RSD PTR " /* Trailing space required */
+#define ACPI_RSDP_SIG_STR "RSD PTR " /* Trailing space required */
 #define ACPI_RSDP_SIG_LEN 8
 typedef struct {
 	char signature[8];
@@ -35,14 +35,14 @@ typedef struct {
 	char reserved[4];
 } acpi_desc_table_hdr_t;
 
-#define ACPI_RSDT_SIG "RSDT"
+#define ACPI_RSDT_SIG_STR "RSDT"
 #define ACPI_RSDT_SIG_LEN 4
 typedef struct acpi_rsdt {
 	acpi_desc_table_hdr_t header;
 	unsigned long entry_ptrs[1];	/* Not really . . . */
 } acpi_rsdt_t;
 
-#define ACPI_SAPIC_SIG "SPIC"
+#define ACPI_SAPIC_SIG_STR "SPIC"
 #define ACPI_SAPIC_SIG_LEN 4
 typedef struct {
 	acpi_desc_table_hdr_t header;

