From: Keith Owens <kaos@sgi.com>
Date: Sun, 05 Dec 2004 04:19:11 +0000
Subject: [RFC] Clear all corrected records as they are read from SAL
Message-Id: <22981.1102220351@ocs3.ocs.com.au>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

This patch compiles but has not been tested.  I am throwing it open for
comments while I test the code.  Against 2.6.10-rc2 or -rc3, with or
without Russ Anderson's per cpu MCA/INIT area patch.

Russ hit a problem while testing recoverable MCA errors.  Because MCA
events are not irq safe, they cannot be logged via salinfo_decode at
the time that they occur.  Instead kernel salinfo.c runs a timer every
few minutes to check for and to clear corrected MCA records.  If a
second recoverable MCA occurs on the same cpu before salinfo_decode has
cleared the first record then OS_MCA reads the record for the first MCA
from SAL, which passes invalid data to the MCA recovery routines.

This patch treats all corrected records the same way, by clearing the
records from SAL as soon as they occur.  CMC and CPE records are
cleared as they are read.  Recoverable MCA records are cleared at the
time that we decide they can be corrected.  If salinfo_decode is not
running or is backlogged then we lose some logging, but that has always
been the case for corrected errors.

I am assuming that all ia64 proms mark CMC and CPE as severity code 2
(corrected error).  Do any vendors have proms that do not mark CMC/CPE
as code 2?


Index: linux/include/asm-ia64/sal.h
=================================--- linux.orig/include/asm-ia64/sal.h	Tue Oct 19 07:55:28 2004
+++ linux/include/asm-ia64/sal.h	Sun Dec  5 14:36:32 2004
@@ -325,6 +325,10 @@ typedef struct sal_log_record_header {
 	efi_guid_t platform_guid;	/* Unique OEM Platform ID */
 } sal_log_record_header_t;
 
+#define sal_log_severity_recoverable	0
+#define sal_log_severity_fatal		1
+#define sal_log_severity_corrected	2
+
 /* Definition of log section header structures */
 typedef struct sal_log_sec_header {
     efi_guid_t guid;			/* Unique Section ID */
Index: linux/arch/ia64/kernel/mca.c
=================================--- linux.orig/arch/ia64/kernel/mca.c	Sun Dec  5 14:12:00 2004
+++ linux/arch/ia64/kernel/mca.c	Sun Dec  5 14:51:11 2004
@@ -234,6 +234,7 @@ static void
 ia64_mca_log_sal_error_record(int sal_info_type)
 {
 	u8 *buffer;
+	sal_log_record_header_t *rh;
 	u64 size;
 	int irq_safe = sal_info_type != SAL_INFO_TYPE_MCA && sal_info_type != SAL_INFO_TYPE_INIT;
 #ifdef IA64_MCA_DEBUG_INFO
@@ -252,7 +253,8 @@ ia64_mca_log_sal_error_record(int sal_in
 			sal_info_type < ARRAY_SIZE(rec_name) ? rec_name[sal_info_type] : "UNKNOWN");
 
 	/* Clear logs from corrected errors in case there's no user-level logger */
-	if (sal_info_type = SAL_INFO_TYPE_CPE || sal_info_type = SAL_INFO_TYPE_CMC)
+	rh = (sal_log_record_header_t *)buffer;
+	if (rh->severity = sal_log_severity_corrected)
 		ia64_sal_clear_state_info(sal_info_type);
 }
 
@@ -880,6 +882,11 @@ ia64_mca_ucmc_handler(void)
 			&ia64_sal_to_os_handoff_state,
 			&ia64_os_to_sal_handoff_state)); 
 
+	if (recover) {
+		sal_log_record_header_t *rh = IA64_LOG_CURR_BUFFER(SAL_INFO_TYPE_MCA);
+		rh->severity = sal_log_severity_corrected;
+		ia64_sal_clear_state_info(SAL_INFO_TYPE_MCA);
+	}
 	/*
 	 *  Wakeup all the processors which are spinning in the rendezvous
 	 *  loop.
Index: linux/arch/ia64/kernel/salinfo.c
=================================--- linux.orig/arch/ia64/kernel/salinfo.c	Sat Dec  4 12:55:38 2004
+++ linux/arch/ia64/kernel/salinfo.c	Sun Dec  5 14:59:01 2004
@@ -19,6 +19,9 @@
  *
  * Jan 28 2004	kaos@sgi.com
  *   Periodically check for outstanding MCA or INIT records.
+ *
+ * Dec  5 2004	kaos@sgi.com
+ *   Standardize which records are cleared automatically.
  */
 
 #include <linux/types.h>
@@ -382,8 +385,11 @@ static void
 salinfo_log_read_cpu(void *context)
 {
 	struct salinfo_data *data = context;
+	sal_log_record_header_t *rh;
 	data->log_size = ia64_sal_get_state_info(data->type, (u64 *) data->log_buffer);
-	if (data->type = SAL_INFO_TYPE_CPE || data->type = SAL_INFO_TYPE_CMC)
+	rh = (sal_log_record_header_t *)(data->log_buffer);
+	/* Clear corrected errors as they are read from SAL */
+	if (rh->severity = sal_log_severity_corrected)
 		ia64_sal_clear_state_info(data->type);
 }
 
@@ -457,6 +463,7 @@ salinfo_log_clear_cpu(void *context)
 static int
 salinfo_log_clear(struct salinfo_data *data, int cpu)
 {
+	sal_log_record_header_t *rh;
 	data->state = STATE_NO_DATA;
 	if (!test_bit(cpu, &data->cpu_event))
 		return 0;
@@ -469,10 +476,9 @@ salinfo_log_clear(struct salinfo_data *d
 		data->saved_num = 0;
 		spin_unlock_irqrestore(&data_saved_lock, flags);
 	}
-	/* ia64_mca_log_sal_error_record or salinfo_log_read_cpu already cleared
-	 * CPE and CMC errors
-	 */
-	if (data->type != SAL_INFO_TYPE_CPE && data->type != SAL_INFO_TYPE_CMC)
+	rh = (sal_log_record_header_t *)(data->log_buffer);
+	/* Corrected errors have already been cleared from SAL */
+	if (rh->severity != sal_log_severity_corrected)
 		call_on_cpu(cpu, salinfo_log_clear_cpu, data);
 	/* clearing a record may make a new record visible */
 	salinfo_log_new_read(cpu, data);

