From: Alex Chiang <achiang@hp.com>
Date: Wed, 27 Feb 2008 23:43:11 +0000
Subject: Re: Tiger oops in ia64_sal_physical_id_info (was [RFC]
Message-Id: <20080227234311.GA29968@ldl.fc.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200802251027.15107.bjorn.helgaas@hp.com>
In-Reply-To: <200802251027.15107.bjorn.helgaas@hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

* Luck, Tony <tony.luck@intel.com>:
> 
> How about a more drastic approach to avoiding the
> problem ... avoid any poking around looking for
> siblings on pre-montecito processors?

That's a good idea, but there are a few issues...

Primarily, SAL_PHYSICAL_ID_INFO returns useful information on HP
pre-montecito platforms. And as we're learning, there isn't a
nice uniform way of figuring out when we should be making this
call and when we shouldn't because:

	(a) Tiger firmware should be returning -1 for an
	unimplemented SAL call, but is hanging instead

	(b) SGI Altix has hard-coded the incorrect SAL version in
	their firmware, so we can't do a simple version check.

In the ideal world, we would just fix (a) to return -1.

In a less ideal world, I would beg SGI fw guys to set their SAL
revision id to 3.2, since that's what they implement.

In reality, I think we have to do some hacky stuff to work around
these firmware issues so that all parties are happy, where happy
is defined as:

	(a) no longer hang Tiger boxes
	(b) SGI machines have proper entries in /proc/cpuinfo
	(c) legacy HP machines have useful information in
	/proc/cpuinfo

So here are the two ideas I had. First, a slight modification to
my earlier patch, where we now check for SGI machines too:

>  ia64_sal_physical_id_info(u16 *splid)                                        
>  {                                                                            
>         struct ia64_sal_retval isrv;                                          
> +                                                                             
> +       if (!ia64_platform_is("sn2") && (sal_revision < SAL_VERSION_CODE(3,2))
> +               return -1;                                                    
> +                                                                             
>         SAL_CALL(isrv, SAL_PHYSICAL_ID_INFO, 0, 0, 0, 0, 0, 0, 0);            
>         if (splid)                                                            
>                 *splid = isrv.v0;                                             

As a slight optimization, I could probably do that check in
ia64_sal_init() and save the results for later for
ia64_sal_physical_id_info to look at.

Second idea is a bit more involved and follows afterwards.

And if anyone has other suggestions too, I'm happy to hear them.

Thanks.

/ac

From: Alex Chiang <achiang@hp.com>
Subject: [PATCH] ia64: workaround tiger hang in ia64_sal_get_physical_id_info

Intel Tiger systems hang if SAL_PHYSICAL_ID_INFO is called
instead of returning -1 like they should.

We can't just check the SAL revision number and avoid this call
if sal_revision < 3.2, because SGI Altix systems have hard-coded
their revision number to 2.9, even though they really implement 3.2.

So look in the XSDT to avoid making the call on Tiger platforms.
Create an interface exposing the XSDT to do so.

Signed-off-by: Alex Chiang <achiang@hp.com>
---
diff --git a/arch/ia64/kernel/acpi.c b/arch/ia64/kernel/acpi.c
index 78f28d8..e5b9cc0 100644
--- a/arch/ia64/kernel/acpi.c
+++ b/arch/ia64/kernel/acpi.c
@@ -69,8 +69,7 @@ unsigned int acpi_cpei_phys_cpuid;
 
 unsigned long acpi_wakeup_address = 0;
 
-#ifdef CONFIG_IA64_GENERIC
-static unsigned long __init acpi_find_rsdp(void)
+static unsigned long acpi_find_rsdp(void)
 {
 	unsigned long rsdp_phys = 0;
 
@@ -81,7 +80,30 @@ static unsigned long __init acpi_find_rsdp(void)
 		       "v1.0/r0.71 tables no longer supported\n");
 	return rsdp_phys;
 }
-#endif
+
+struct acpi_table_xsdt *
+acpi_find_xsdt(void)
+{
+	unsigned long rsdp_phys;
+	struct acpi_table_rsdp *rsdp;
+	struct acpi_table_xsdt *xsdt;
+	struct acpi_table_header *hdr;
+
+	rsdp_phys = acpi_find_rsdp();
+	if (!rsdp_phys)
+		return NULL;
+
+	rsdp = (struct acpi_table_rsdp *)__va(rsdp_phys);
+	if (strncmp(rsdp->signature, ACPI_SIG_RSDP, sizeof(ACPI_SIG_RSDP) - 1))
+		return NULL;
+
+	xsdt = (struct acpi_table_xsdt *)__va(rsdp->xsdt_physical_address);
+	hdr = &xsdt->header;
+	if (strncmp(hdr->signature, ACPI_SIG_XSDT, sizeof(ACPI_SIG_XSDT) - 1))
+		return NULL;
+
+	return xsdt;
+}
 
 const char __init *
 acpi_get_sysname(void)
diff --git a/arch/ia64/kernel/sal.c b/arch/ia64/kernel/sal.c
index f44fe84..a75de51 100644
--- a/arch/ia64/kernel/sal.c
+++ b/arch/ia64/kernel/sal.c
@@ -286,6 +286,54 @@ ia64_sal_cache_flush (u64 cache_type)
 }
 EXPORT_SYMBOL_GPL(ia64_sal_cache_flush);
 
+/*
+ * Intel Tiger systems implement SAL revision 3.1, which does not
+ * define SAL_PHYSICAL_ID_INFO. If this call is made on those platforms,
+ * they *should* return -1 to indicate the call is unimplemented, but
+ * instead, they hang.
+ *
+ * It might be easy to simply check the SAL revision number and avoid
+ * this call if sal_revision < 3.2, but SGI Altix systems have hard-coded
+ * their revision number to 2.9, even though they really implement 3.2.
+ *
+ * So we have to grovel in ACPI's XSDT to try and detect Tiger systems
+ * and avoid making this SAL call.
+ */
+#include <linux/acpi.h>
+static int
+is_intel_tiger(void)
+{
+	struct acpi_table_xsdt *xsdt;
+	struct acpi_table_header *hdr;
+
+	xsdt = acpi_find_xsdt();
+	if (!xsdt)
+		return 0;
+
+	hdr = &xsdt->header;
+	if (strncmp(hdr->oem_id, "INTEL", 5) ||
+		(!strncmp(hdr->oem_table_id, "SR870BH2", 8) &&
+		!strncmp(hdr->oem_table_id, "SR870BN4", 8)))
+		return 0;
+
+	return 1;
+}
+
+s64
+ia64_sal_physical_id_info(u16 *splid)
+{
+	struct ia64_sal_retval isrv;
+
+	if (is_intel_tiger())
+		return -1;
+
+	SAL_CALL(isrv, SAL_PHYSICAL_ID_INFO, 0, 0, 0, 0, 0, 0, 0);
+	if (splid)
+		*splid = isrv.v0;
+	return isrv.status;
+}
+EXPORT_SYMBOL_GPL(ia64_sal_physical_id);
+
 void __init
 ia64_sal_init (struct ia64_sal_systab *systab)
 {
diff --git a/include/asm-ia64/sal.h b/include/asm-ia64/sal.h
index 2251118..d30100d 100644
--- a/include/asm-ia64/sal.h
+++ b/include/asm-ia64/sal.h
@@ -652,6 +652,8 @@ typedef struct err_rec {
 
 extern s64 ia64_sal_cache_flush (u64 cache_type);
 extern void __init check_sal_cache_flush (void);
+/* Get physical processor die mapping in the platform. */
+extern s64 ia64_sal_physical_id_info(u16 *splid);
 
 /* Initialize all the processor and platform level instruction and data caches */
 static inline s64
@@ -802,17 +804,6 @@ ia64_sal_update_pal (u64 param_buf, u64 scratch_buf, u64 scratch_buf_size,
 	return isrv.status;
 }
 
-/* Get physical processor die mapping in the platform. */
-static inline s64
-ia64_sal_physical_id_info(u16 *splid)
-{
-	struct ia64_sal_retval isrv;
-	SAL_CALL(isrv, SAL_PHYSICAL_ID_INFO, 0, 0, 0, 0, 0, 0, 0);
-	if (splid)
-		*splid = isrv.v0;
-	return isrv.status;
-}
-
 extern unsigned long sal_platform_features;
 
 extern int (*salinfo_platform_oemdata)(const u8 *, u8 **, u64 *);
diff --git a/include/linux/acpi.h b/include/linux/acpi.h
index 2c7e003..35e973d 100644
--- a/include/linux/acpi.h
+++ b/include/linux/acpi.h
@@ -90,6 +90,7 @@ int __init acpi_table_parse_entries(char *id, unsigned long table_size,
 int acpi_table_parse_madt (enum acpi_madt_type id, acpi_table_entry_handler handler, unsigned int max_entries);
 int acpi_parse_mcfg (struct acpi_table_header *header);
 void acpi_table_print_madt_entry (struct acpi_subtable_header *madt);
+struct acpi_table_xsdt * acpi_find_xsdt(void);
 
 /* the following four functions are architecture-dependent */
 #ifdef CONFIG_HAVE_ARCH_PARSE_SRAT
