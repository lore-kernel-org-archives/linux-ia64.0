From: Keith Owens <kaos@sgi.com>
Date: Thu, 30 Oct 2003 08:40:31 +0000
Subject: [patch 3/4] kernel salinfo changes
Message-Id: <marc-linux-ia64-106750328118393@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

patch 3 - Add the ability for user space salinfo to ask kernel salinfo
          and/or the prom to decode the oem data sections of SAL records.

The user space salinfo decode program can only dump oem data areas in
hex, every ia64 platform has different oem data.  One option is to have
OEM specific versions of the user space salinfo program, but that
introduces version skew between user space and the kernel.  By
definition, the prom knows best about what the oemdata means.

This patch allows user space to write 'oemdata <cpu> <offset>' to
/proc/sal/mca/data, passing the offset within the record of the EFI
GUID at the start of the section that contains oemdata.  If the
platform supports decoding of the oemdata then the next read from
/proc/sal/mca/data will return the decoded text.  If the platform does
not support decoding of oemdata, it returns EOF and user space salinfo
defaults to printing oem data in hex, as before.


diff -ur 2.4.23-pre8-cset-1.1069.1.143-to-1.1108-salinfo2/arch/ia64/kernel/salinfo.c 2.4.23-pre8-cset-1.1069.1.143-to-1.1108-salinfo3/arch/ia64/kernel/salinfo.c
--- 2.4.23-pre8-cset-1.1069.1.143-to-1.1108-salinfo2/arch/ia64/kernel/salinfo.c	Thu Oct 30 18:40:02 2003
+++ 2.4.23-pre8-cset-1.1069.1.143-to-1.1108-salinfo3/arch/ia64/kernel/salinfo.c	Thu Oct 30 18:43:53 2003
@@ -88,6 +88,7 @@
 /* State transitions.  Actions are :-
  *   Write "read <cpunum>" to the data file.
  *   Write "clear <cpunum>" to the data file.
+ *   Write "oemdata <cpunum> <offset> to the data file.
  *   Read from the data file.
  *   Close the data file.
  *
@@ -96,15 +97,24 @@
  * NO_DATA
  *    write "read <cpunum>" -> NO_DATA or LOG_RECORD.
  *    write "clear <cpunum>" -> NO_DATA or LOG_RECORD.
+ *    write "oemdata <cpunum> <offset> -> return -EINVAL.
  *    read data -> return EOF.
  *    close -> unchanged.  Free record areas.
  *
  * LOG_RECORD
  *    write "read <cpunum>" -> NO_DATA or LOG_RECORD.
  *    write "clear <cpunum>" -> NO_DATA or LOG_RECORD.
+ *    write "oemdata <cpunum> <offset> -> format the oem data, goto OEMDATA.
  *    read data -> return the INIT/MCA/CMC/CPE record.
  *    close -> unchanged.  Keep record areas.
  *
+ * OEMDATA
+ *    write "read <cpunum>" -> NO_DATA or LOG_RECORD.
+ *    write "clear <cpunum>" -> NO_DATA or LOG_RECORD.
+ *    write "oemdata <cpunum> <offset> -> format the oem data, goto OEMDATA.
+ *    read data -> return the formatted oemdata.
+ *    close -> unchanged.  Keep record areas.
+ *
  * Closing the data file does not change the state.  This allows shell scripts
  * to manipulate salinfo data, each shell redirection opens the file, does one
  * action then closes it again.  The record areas are only freed at close when
@@ -113,6 +123,7 @@
 enum salinfo_state {
 	STATE_NO_DATA,
 	STATE_LOG_RECORD,
+	STATE_OEMDATA,
 };
 
 struct salinfo_data {
@@ -120,6 +131,8 @@
 	struct semaphore	sem;		/* count of cpus with outstanding events (bits set in cpu_event) */
 	u8			*log_buffer;
 	u64			log_size;
+	u8			*oemdata;	/* decoded oem data */
+	u64			oemdata_size;
 	int			open;		/* single-open to prevent races */
 	u8			type;
 	u8			saved_num;	/* using a saved record? */
@@ -133,6 +146,35 @@
 
 static spinlock_t data_lock, data_saved_lock;
 
+/** salinfo_platform_oemdata - optional callback to decode oemdata from an error
+ * record.
+ * @sect_header: pointer to the start of the section to decode.
+ * @oemdata: returns vmalloc area containing the decded output.
+ * @oemdata_size: returns length of decoded output (strlen).
+ *
+ * Description: If user space asks for oem data to be decoded by the kernel
+ * and/or prom and the platform has set salinfo_platform_oemdata to the address
+ * of a platform specific routine then call that routine.  salinfo_platform_oemdata
+ * vmalloc's and formats its output area, returning the address of the text
+ * and its strlen.  Returns 0 for success, -ve for error.  The callback is
+ * invoked on the cpu that generated the error record.
+ */
+int (*salinfo_platform_oemdata)(const u8 *sect_header, u8 **oemdata, u64 *oemdata_size);
+
+struct salinfo_platform_oemdata_parms {
+	const u8 *efi_guid;
+	u8 **oemdata;
+	u64 *oemdata_size;
+	int ret;
+};
+
+static void
+salinfo_platform_oemdata_cpu(void *context)
+{
+	struct salinfo_platform_oemdata_parms *parms = context;
+	parms->ret = salinfo_platform_oemdata(parms->efi_guid, parms->oemdata, parms->oemdata_size);
+}
+
 static void
 shift1_data_saved (struct salinfo_data *data, int shift)
 {
@@ -287,7 +329,9 @@
 
 	if (data->state = STATE_NO_DATA) {
 		vfree(data->log_buffer);
+		vfree(data->oemdata);
 		data->log_buffer = NULL;
+		data->oemdata = NULL;
 	}
 	spin_lock(&data_lock);
 	data->open = 0;
@@ -355,14 +399,24 @@
 	struct salinfo_data *data = entry->data;
 	void *saldata;
 	size_t size;
+	u8 *buf;
+	u64 bufsize;
 
-	if (data->new_read)
-		salinfo_log_new_read(data);
-	if (*ppos >= data->log_size)
+	if (data->state = STATE_LOG_RECORD) {
+		buf = data->log_buffer;
+		bufsize = data->log_size;
+	} else if (data->state = STATE_OEMDATA) {
+		buf = data->oemdata;
+		bufsize = data->oemdata_size;
+	} else {
+		buf = NULL;
+		bufsize = 0;
+	}
+	if (*ppos >= bufsize)
 		return 0;
 
-	saldata = data->log_buffer + file->f_pos;
-	size = data->log_size - file->f_pos;
+	saldata = buf + file->f_pos;
+	size = bufsize - file->f_pos;
 	if (size > count)
 		size = count;
 	if (copy_to_user(buffer, saldata, size))
@@ -412,6 +466,7 @@
 	struct salinfo_data *data = entry->data;
 	char cmd[32];
 	size_t size;
+	u32 offset;
 	int cpu;
 
 	size = sizeof(cmd);
@@ -426,6 +481,23 @@
 		int ret;
 		if ((ret = salinfo_log_clear(data, cpu)))
 			count = ret;
+	} else if (sscanf(cmd, "oemdata %d %d", &cpu, &offset) = 2) {
+		if (data->state != STATE_LOG_RECORD && data->state != STATE_OEMDATA)
+			return -EINVAL;
+		if (offset > data->log_size - sizeof(efi_guid_t))
+			return -EINVAL;
+		data->state = STATE_OEMDATA;
+		if (salinfo_platform_oemdata) {
+			struct salinfo_platform_oemdata_parms parms = {
+				.efi_guid = data->log_buffer + offset,
+				.oemdata = &data->oemdata,
+				.oemdata_size = &data->oemdata_size
+			};
+			call_on_cpu(cpu, salinfo_platform_oemdata_cpu, &parms);
+			if (parms.ret)
+				count = parms.ret;
+		} else
+			data->oemdata_size = 0;
 	} else
 		return -EINVAL;
 
diff -ur 2.4.23-pre8-cset-1.1069.1.143-to-1.1108-salinfo2/include/asm-ia64/sal.h 2.4.23-pre8-cset-1.1069.1.143-to-1.1108-salinfo3/include/asm-ia64/sal.h
--- 2.4.23-pre8-cset-1.1069.1.143-to-1.1108-salinfo2/include/asm-ia64/sal.h	Thu Oct 30 18:34:11 2003
+++ 2.4.23-pre8-cset-1.1069.1.143-to-1.1108-salinfo3/include/asm-ia64/sal.h	Thu Oct 30 18:43:53 2003
@@ -806,6 +806,8 @@
 
 extern unsigned long sal_platform_features;
 
+extern int (*salinfo_platform_oemdata)(const u8 *, u8 **, u64 *);
+
 #endif /* __ASSEMBLY__ */
 
 #endif /* _ASM_IA64_SAL_H */

