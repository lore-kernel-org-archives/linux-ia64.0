From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Wed, 05 Mar 2003 00:01:20 +0000
Subject: Re: [Linux-ia64] [patch] 2.4.20-021210 misaligned sal error record
Message-Id: <marc-linux-ia64-105590709805965@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805925@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805925@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Tue, 25 Feb 2003 12:53:35 +1100, Keith Owens <kaos@sgi.com> said:

  Keith> On Mon, 24 Feb 2003 17:42:48 -0800, David Mosberger
  Keith> <davidm@napali.hpl.hp.com> wrote:
  >>>>>>> On Tue, 25 Feb 2003 11:24:35 +1100, Keith Owens
  >>>>>>> <kaos@sgi.com> said:
  >>
  Keith> - sal_log_mod_error_info_t cache_check_info[16]; -
  Keith> sal_log_mod_error_info_t tlb_check_info[16]; -
  Keith> sal_log_mod_error_info_t bus_check_info[16]; -
  Keith> sal_log_mod_error_info_t reg_file_check_info[16]; -
  Keith> sal_log_mod_error_info_t ms_check_info[16]; +
  Keith> sal_log_mod_error_info_t cache_check_info[0]; +
  Keith> sal_log_mod_error_info_t tlb_check_info[0]; +
  Keith> sal_log_mod_error_info_t bus_check_info[0]; +
  Keith> sal_log_mod_error_info_t reg_file_check_info[0]; +
  Keith> sal_log_mod_error_info_t ms_check_info[0];
  >>  Somehow I doubt a declaration of this form is a good idea.  If
  >> the records are all variable length, wouldn't it be saner to just
  >> declare this with something along the lines of:
  >> 
  Keith> + sal_log_mod_error_info_t check_info[0];
  >>  and then provide separate macros to access the indiviual
  >> portions?

  Keith> Either works, but nobody really cares about the various
  Keith> *check_info sections.  What we care about is the processor
  Keith> static data that comes after these sections and is addressed
  Keith> via the new function.  This was the minimal change to
  Keith> correctly access the processor static data, it is a one line
  Keith> change to mca.c.

  Keith> Replacing the individual *check_info[0] sections with a
  Keith> single check_info[0] means more changes to mca.c to use the
  Keith> new names.  It also diverges from the SAL specification which
  Keith> lists the individual fields.  Since the end result would be
  Keith> exactly the same as the existing code, I went for the minimal
  Keith> change and kept SAL documentation compatibility.  Blame the
  Keith> SAL docs, I do ;).

I don't think the proper solution requires many more changes to mca.c.
If we don't fix it properly, I'm sure it will trip someone again
later on.

Below is a proposed patch (btw: I think your patch had a bug:
addr_processor_static_info() didn't skip the cpuid structure).

The patch breaks mca_test(), which is used only if MCA_TEST is
defined.  But the old code worked for the wrong reasons, so I
think this needs updating anyhow.

Could someone test this to verify it works as intended (it does
compile, but that's as far as I tested it).

Thanks,

	--david

=== arch/ia64/kernel/mca.c 1.17 vs edited ==--- 1.17/arch/ia64/kernel/mca.c	Tue Feb  4 17:06:10 2003
+++ edited/arch/ia64/kernel/mca.c	Tue Mar  4 15:37:15 2003
@@ -825,7 +825,7 @@
 	plog_ptr=(ia64_err_rec_t *)IA64_LOG_CURR_BUFFER(SAL_INFO_TYPE_INIT);
 	proc_ptr = &plog_ptr->proc_err;
 
-	ia64_process_min_state_save(&proc_ptr->processor_static_info.min_state_area);
+	ia64_process_min_state_save(&SAL_LPI_PSI_INFO(proc_ptr)->min_state_area);
 
 	/* Clear the INIT SAL logs now that they have been saved in the OS buffer */
 	ia64_sal_clear_state_info(SAL_INFO_TYPE_INIT);
@@ -1620,7 +1620,7 @@
 	 *  absent. Also, current implementations only allocate space for number of
 	 *  elements used.  So we walk the data pointer from here on.
 	 */
-	p_data = &slpi->cache_check_info[0];
+	p_data = &slpi->info[0];
 
 	/* Print the cache check information if any*/
 	for (i = 0 ; i < slpi->valid.num_cache_check; i++, p_data++)
=== include/asm-ia64/sal.h 1.13 vs edited ==--- 1.13/include/asm-ia64/sal.h	Thu Feb  6 11:39:47 2003
+++ edited/include/asm-ia64/sal.h	Tue Mar  4 15:48:43 2003
@@ -336,6 +336,11 @@
 	struct ia64_fpreg fr[128];
 } sal_processor_static_info_t;
 
+struct sal_cpuid_info {
+	u64 regs[5];
+	u64 reserved;
+};
+
 typedef struct sal_log_processor_info {
 	sal_log_section_hdr_t header;
 	struct {
@@ -354,17 +359,34 @@
 	u64 proc_error_map;
 	u64 proc_state_parameter;
 	u64 proc_cr_lid;
-	sal_log_mod_error_info_t cache_check_info[16];
-	sal_log_mod_error_info_t tlb_check_info[16];
-	sal_log_mod_error_info_t bus_check_info[16];
-	sal_log_mod_error_info_t reg_file_check_info[16];
-	sal_log_mod_error_info_t ms_check_info[16];
-	struct {
-		u64 regs[5];
-		u64 reserved;
-	} cpuid_info;
-	sal_processor_static_info_t processor_static_info;
+	/*
+	 * The rest of this structure consists of variable-length arrays, which can't be
+	 * expressed in C.
+	 */
+	sal_log_mod_error_info_t info[0];
+	/*
+	 * This is what the rest looked like if C supported variable-length arrays:
+	 *
+	 * sal_log_mod_error_info_t cache_check_info[.valid.num_cache_check];
+	 * sal_log_mod_error_info_t tlb_check_info[.valid.num_tlb_check];
+	 * sal_log_mod_error_info_t bus_check_info[.valid.num_bus_check];
+	 * sal_log_mod_error_info_t reg_file_check_info[.valid.num_reg_file_check];
+	 * sal_log_mod_error_info_t ms_check_info[.valid.num_ms_check];
+	 * struct sal_cpuid_info cpuid_info;
+	 * sal_processor_static_info_t processor_static_info;
+	 */
 } sal_log_processor_info_t;
+
+/* Given a sal_log_processor_info_t pointer, return a pointer to the processor_static_info: */
+#define SAL_LPI_PSI_INFO(l)								\
+({	sal_log_processor_info_t *_l = (l);						\
+	((sal_processor_static_info_t *)						\
+	 ((char *) _l + ((_l->valid.num_cache_check + _l->valid.num_tlb_check		\
+			  + _l->valid.num_bus_check + _l->valid.num_reg_file_check	\
+			  + _l->valid.num_ms_check) * sizeof(sal_log_mod_error_info_t)	\
+			 + sizeof(struct sal_cpuid_info))));				\
+})
+
 
 /* platform error log structures */
 

