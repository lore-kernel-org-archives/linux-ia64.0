From: "H . J . Lu" <hjl@valinux.com>
Date: Sun, 10 Sep 2000 00:39:26 +0000
Subject: Re: [Linux-ia64] kernel update (relative to v2.4.0-test8)
MIME-Version: 1
Content-Type: multipart/mixed; boundary="VbJkn9YxBvnuCH5J"
Message-Id: <marc-linux-ia64-105590678205477@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205111@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205111@msgid-missing>
To: linux-ia64@vger.kernel.org

--VbJkn9YxBvnuCH5J
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Sat, Sep 09, 2000 at 05:17:12PM -0700, David Mosberger wrote:
> >>>>> On Sat, 9 Sep 2000 14:49:52 -0700, "H . J . Lu" <hjl@valinux.com> said:
> 
>   HJ> Yes, I did "make dep". What should include/asm-ia64/offsets.h
>   HJ> look like? That may explain many things.
> 
> Well, it depends on your kernel configuration.  If you did a "make
> dep", you should have the right values in there.
> 
> I'm not sure why the new kernel isn't working for you.  Nothing has
> changed in the kernel that would explain an infinite stream of irq 0.
> 

I am going through my build log. I found at least 2 problems:

1. In inclide/asm-ia64/processor.h, there is

# define loops_per_sec()       loops_per_sec

It is bad if the versioned symbol is enabled.

2. ACPI_RSDT_SIG is defined both as a string and an integer in
2 different header files. In include/linux/acpi.h

#define ACPI_RSDT_SIG  0x54445352 /* 'RSDT' */

In include/asm-ia64/acpi-ext.h

#define ACPI_RSDT_SIG "RSDT"

It is very confusing.

I am enclosing 2 patches. Please take a look.

Thanks.


H.J.

--VbJkn9YxBvnuCH5J
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="macro.patch"

--- linux/arch/ia64/kernel/setup.c.macro	Sat Sep  9 17:20:57 2000
+++ linux/arch/ia64/kernel/setup.c	Sat Sep  9 17:21:25 2000
@@ -320,7 +320,7 @@ get_cpuinfo (char *buffer)
 			     features,
 			     c->ppn, c->number, c->proc_freq / 1000000, c->proc_freq % 1000000,
 			     c->itc_freq / 1000000, c->itc_freq % 1000000,
-			     loops_per_sec() / 500000, (loops_per_sec() / 5000) % 100);
+			     ia64_loops_per_sec() / 500000, (ia64_loops_per_sec() / 5000) % 100);
         }
 	return p - buffer;
 }
--- linux/include/asm-ia64/processor.h.macro	Sat Sep  9 17:20:05 2000
+++ linux/include/asm-ia64/processor.h	Sat Sep  9 17:20:27 2000
@@ -253,9 +253,9 @@ struct cpuinfo_ia64 {
 #define my_cpu_data		cpu_data[smp_processor_id()]
 
 #ifdef CONFIG_SMP
-# define loops_per_sec()	my_cpu_data.loops_per_sec
+# define ia64_loops_per_sec()	my_cpu_data.loops_per_sec
 #else
-# define loops_per_sec()	loops_per_sec
+# define ia64_loops_per_sec()	loops_per_sec
 #endif
 
 extern struct cpuinfo_ia64 cpu_data[NR_CPUS];

--VbJkn9YxBvnuCH5J
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="string.patch"

--- linux/arch/ia64/kernel/acpi.c.string	Sat Sep  9 17:30:07 2000
+++ linux/arch/ia64/kernel/acpi.c	Sat Sep  9 17:31:11 2000
@@ -233,7 +233,7 @@ acpi_parse(acpi_rsdp_t *rsdp)
 
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

--VbJkn9YxBvnuCH5J--

