From: Alex Williamson <alex_williamson@hp.com>
Date: Mon, 10 Feb 2003 18:06:05 +0000
Subject: [Linux-ia64] [PATCH] memory scrubbing
MIME-Version: 1
Content-Type: multipart/mixed; boundary="------------FF8980E8A7315E27CD66157F"
Message-Id: <marc-linux-ia64-105590709805832@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org

This is a multi-part message in MIME format.
--------------FF8980E8A7315E27CD66157F
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit


  Attached is a patch that adds lightweight memory scrubbing for
memory errors reported by CMCs and CPEs.  The goal is simply to
mark addresses reported by these corrected errors as dirty such
that the corrected value gets written back to memory.  For
platforms that do no support hardware memory scrubbing, this
should help ensure that single bit errors don't become multi-bit
errors and should reduce the occurrence of multiple CMCs for
the same memory address.  I'm assuming that platforms that do
support hardware scrubbing will fix single bit errors at the
chipset, eliminating the CMC, and thus making this addition
extremely lightweight.

   To scrub the memory, I simply issue an lfetch.excl to the
faulting address.  According to the Itanium 2 Optimization guide,
this will look like a write on the bus and puts the cacheline in
the M(odified) state.  Thanks to David for recommending this
method of scrubbing.

   To determine if an address needs scrubbing, I look for the
following:

  CMC - bus error w/ the eb (external bus) bit set.
  CPE - memory device error.

Ideally for the CMC, we could get the target address from the
bus error log.  Unfortunately, the CMC hardly ever (never in
my experience) sets the target address as valid.  Therefore,
if I see the signature from the CMC, but not a target address,
I kick the CPE poll to trigger (if we're in polling mode for
CPEs).

   I've also updated the CPE polling to poll on all processors.
For multi-node systems, this makes sure we get all the logs
we're after.

   This patch also fixes the timestamp for MCA logs.  The date
was correctly changed to be printed as BCD, but the time was
still being printed as decimal.  This patch applies cleanly
against 2.4.20 + ia64-021210 (I think 2.5 is missing the CPE
polling patch, which causes failures).  Feedback welcome.  Thanks,

	Alex

--
Alex Williamson                                  Linux Development Lab
alex_williamson@hp.com                                 Hewlett Packard
970-898-9173                                          Fort Collins, CO
--------------FF8980E8A7315E27CD66157F
Content-Type: text/plain; charset=us-ascii;
 name="cmc_cpe_memory_srcub.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="cmc_cpe_memory_srcub.diff"

--- arch/ia64/kernel/mca.c	11 Dec 2002 18:50:43 -0000	1.7
+++ arch/ia64/kernel/mca.c	7 Feb 2003 23:16:17 -0000
@@ -45,6 +45,7 @@
 #include <linux/timer.h>
 #include <linux/module.h>
 #include <linux/kernel.h>
+#include <linux/smp.h>
 
 #include <asm/machvec.h>
 #include <asm/page.h>
@@ -53,6 +54,7 @@
 #include <asm/sal.h>
 #include <asm/mca.h>
 
+#include <asm/processor.h>
 #include <asm/irq.h>
 #include <asm/hw_irq.h>
 
@@ -139,6 +141,19 @@ ia64_mca_log_sal_error_record(int sal_in
 	 */
 
 	platform_err = ia64_log_print(sal_info_type, (prfunc_t)printk);
+
+	switch(sal_info_type) {
+		/*
+		 * For CMCs & CPEs, we can try to scrub memory. 
+		 */
+		case SAL_INFO_TYPE_CMC:
+		case SAL_INFO_TYPE_CPE:
+			ia64_mca_scrub_check(sal_info_type);
+			break;
+		default:
+			break;
+	}
+
 	/* temporary: only clear SAL logs on hardware-corrected errors
 		or if we're logging an error after an MCA-initiated reboot */
 	if ((sal_info_type > 1) || (called_from_init))
@@ -160,7 +175,7 @@ mca_handler_platform (void)
 void
 ia64_mca_cpe_int_handler (int cpe_irq, void *arg, struct pt_regs *ptregs)
 {
-	IA64_MCA_DEBUG("ia64_mca_cpe_int_handler: received interrupt. vector = %#x\n", cpe_irq);
+	IA64_MCA_DEBUG("ia64_mca_cpe_int_handler: received interrupt. CPU:%d vector = %#x\n", smp_processor_id(), cpe_irq);
 
 	/* Get the CMC error record and log it */
 	ia64_mca_log_sal_error_record(SAL_INFO_TYPE_CPE, 0);
@@ -820,6 +835,21 @@ static ia64_state_log_t ia64_state_log[I
 #define IA64_LOG_CURR_BUFFER(it)   (void *)((ia64_state_log[it].isl_log[IA64_LOG_CURR_INDEX(it)]))
 
 /*
+ *  ia64_mca_cpe_int_caller
+ *
+ * 	Call CPE interrupt handler, only purpose is to have a
+ * 	smp_call_function callable entry.
+ *
+ * Inputs   :	dummy(unused)
+ * Outputs  :	None
+ * */
+static void
+ia64_mca_cpe_int_caller(void *dummy)
+{
+	ia64_mca_cpe_int_handler(0, NULL, NULL);
+}
+
+/*
  *  ia64_mca_cpe_poll
  *
  *	Poll for Corrected Platform Errors (CPEs), dynamically adjust
@@ -838,7 +868,8 @@ ia64_mca_cpe_poll (unsigned long dummy)
 	start_index = IA64_LOG_CURR_INDEX(SAL_INFO_TYPE_CPE);
 
 	/* Call the interrupt handler */
-	ia64_mca_cpe_int_handler(0, NULL, NULL);
+	smp_call_function(ia64_mca_cpe_int_caller, NULL, 1, 1);
+	ia64_mca_cpe_int_caller(NULL);
 
 	/*
 	 * If a log was recorded, increase our polling frequency,
@@ -1077,7 +1108,7 @@ ia64_log_rec_header_print (sal_log_recor
 {
 	prfunc("+Err Record ID: %d    SAL Rev: %2x.%02x\n", lh->id,
 		lh->revision.major, lh->revision.minor);
-	prfunc("+Time: %02x/%02x/%02x%02x %02d:%02d:%02d    Severity %d\n",
+	prfunc("+Time: %02x/%02x/%02x%02x %02x:%02x:%02x    Severity %d\n",
 		lh->timestamp.slh_month, lh->timestamp.slh_day,
 		lh->timestamp.slh_century, lh->timestamp.slh_year,
 		lh->timestamp.slh_hour, lh->timestamp.slh_minute,
@@ -1987,4 +2018,121 @@ ia64_log_print(int sal_info_type, prfunc
 		break;
 	}
 	return platform_err;
+}
+
+/*
+ * ia64_mca_scrub_proc_dev_err
+ *
+ *  Checks for external, corrected bus checks that may indicate memory
+ *  scrubbing would be useful.
+ *
+ *  Inputs   :  slpi          (error record structure)
+ *              sal_info_type (SAL_INFO_TYPE_{MCA,INIT,CMC,CPE})
+ *  Outputs  :  None
+ */
+static void
+ia64_mca_scrub_proc_dev_err(sal_log_processor_info_t *slpi, int sal_info_type)
+{
+	sal_log_mod_error_info_t *p_data;
+	int                      i;
+
+	p_data = &slpi->cache_check_info[0];
+
+	/* Skip over the cache check and tlb checks */
+	p_data += slpi->valid.num_cache_check;
+	p_data += slpi->valid.num_tlb_check;
+
+	for (i = 0 ; i < slpi->valid.num_bus_check; i++, p_data++) {
+		sal_log_mod_error_info_t *bus_check_info;
+		pal_bus_check_info_t     *info;
+
+		bus_check_info = p_data;
+
+		if (!bus_check_info->valid.check_info)
+			continue;
+
+		/* Found a valid bus check, see if it matches */
+		info = (pal_bus_check_info_t *)&bus_check_info->check_info;
+
+		if (info->eb) {
+			if (info->tv) {
+				if (VALID_PAGE(virt_to_page(phys_to_virt(bus_check_info->target_identifier)))) {
+					printk("ia64_mca_scrub_proc_dev_err: Scrubbing memory @ 0x%lx\n",
+					       bus_check_info->target_identifier);
+					prefetchw(phys_to_virt(bus_check_info->target_identifier));
+				}
+			} else if (sal_info_type == SAL_INFO_TYPE_CMC &&
+			                  timer_pending(&cpe_poll_timer)) {
+				/* poll for CPE now */
+				mod_timer(&cpe_poll_timer, jiffies);
+			}
+		}
+	}
+}
+
+/*
+ * ia64_mca_scrub_mem_dev_err
+ *
+ *  Checks for valid address in memory error record and tries to scrub it.
+ *
+ *  Inputs   :  mdei (error record structure)
+ *  Outputs  :  None
+ */
+static void
+ia64_mca_scrub_mem_dev_err(sal_log_mem_dev_err_info_t *mdei)
+{
+	if (mdei->valid.physical_addr) {
+		if (VALID_PAGE(virt_to_page(phys_to_virt(mdei->physical_addr)))) {
+			printk("ia64_mca_scrub_mem_dev_err: Scrubbing memory @ 0x%lx\n",
+			       mdei->physical_addr);
+			prefetchw(phys_to_virt(mdei->physical_addr));
+		}
+
+		if (mdei->header.recovery_info & IA64_SAL_ERROR_RECOVERY_VALID) {
+			if (mdei->header.recovery_info & IA64_SAL_ERROR_RECOVERY_THRESHOLD) {
+				/*
+				 * TODO: Dynamically deallocate/reserve page
+				 * from future use
+				 */
+				printk("Error threshold exceeded (0x%02x)[0x%lx]\n",
+				       mdei->header.recovery_info, mdei->physical_addr);
+			}
+
+		}
+	}
+}
+
+/*
+ * ia64_mca_scrub_check
+ *
+ *  Check log buffers for memory errors for scrubbing.
+ *
+ *  Inputs   :  sal_info_type (SAL_INFO_TYPE_{MCA,INIT,CMC,CPE})
+ *  Outputs  :  None
+ */
+void
+ia64_mca_scrub_check(int sal_info_type)
+{
+	sal_log_record_header_t  *lh = IA64_LOG_CURR_BUFFER(sal_info_type);
+	int                      n_sects;
+	int                      ercd_pos;
+	sal_log_section_hdr_t    *slsh;
+
+	if (!lh)
+		return;
+
+	if ((ercd_pos = sizeof(sal_log_record_header_t)) >= lh->len)
+		return;
+
+	for (n_sects = 0; (ercd_pos < lh->len); n_sects++, ercd_pos += slsh->len) {
+
+		/* point to next section header */
+		slsh = (sal_log_section_hdr_t *)((char *)lh + ercd_pos);
+
+		if (efi_guidcmp(slsh->guid, SAL_PROC_DEV_ERR_SECT_GUID) == 0) {
+			ia64_mca_scrub_proc_dev_err((sal_log_processor_info_t *)slsh, sal_info_type);
+		} else if (efi_guidcmp(slsh->guid, SAL_PLAT_MEM_DEV_ERR_SECT_GUID) == 0) {
+			ia64_mca_scrub_mem_dev_err((sal_log_mem_dev_err_info_t *)slsh);
+		}
+	}
 }
--- include/asm-ia64/mca.h	11 Dec 2002 18:51:26 -0000	1.4
+++ include/asm-ia64/mca.h	5 Feb 2003 03:59:49 -0000
@@ -137,6 +137,7 @@ extern int  ia64_log_print(int,prfunc_t)
 extern void ia64_mca_cmc_vector_setup(void);
 extern void ia64_mca_check_errors( void );
 extern u64  ia64_log_get(int, prfunc_t);
+extern void ia64_mca_scrub_check(int);
 
 #define PLATFORM_CALL(fn, args)	printk("Platform call TBD\n")
 
--- include/asm-ia64/sal.h	10 Sep 2002 20:13:29 -0000	1.5
+++ include/asm-ia64/sal.h	5 Feb 2003 03:58:49 -0000
@@ -309,11 +309,20 @@ typedef struct sal_log_record_header
 /* Definition of log section header structures */
 typedef struct sal_log_sec_header
 {
-    efi_guid_t          guid;       /* Unique Section ID */
-    sal_log_revision_t  revision;   /* Major and Minor revision of Section */
-    u16                 reserved;
-    u32                 len;        /* Section length */
+    efi_guid_t          guid;           /* Unique Section ID */
+    sal_log_revision_t  revision;       /* Major and Minor revision of Section */
+    u8                  recovery_info;  /* Extra info about error */
+    u8                  reserved;
+    u32                 len;            /* Section length */
 } sal_log_section_hdr_t;
+
+#define IA64_SAL_ERROR_RECOVERY_VALID     (1<<7)
+#define IA64_SAL_ERROR_RECOVERY_NOT_AVAIL (1<<4)
+#define IA64_SAL_ERROR_RECOVERY_THRESHOLD (1<<3)
+#define IA64_SAL_ERROR_RECOVERY_RESET     (1<<2)
+#define IA64_SAL_ERROR_RECOVERY_TAINTED   (1<<1)
+#define IA64_SAL_ERROR_RECOVERY_CORRECTED (1<<0)
+
 
 typedef struct sal_log_mod_error_info
 {

--------------FF8980E8A7315E27CD66157F--


