From: Keith Owens <kaos@sgi.com>
Date: Wed, 24 Dec 2003 06:26:38 +0000
Subject: Re: [PATCH 2.4] salinfo patch
Message-Id: <marc-linux-ia64-107224725703464@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-107214192720071@msgid-missing>
In-Reply-To: <marc-linux-ia64-107214192720071@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, 23 Dec 2003 17:37:48 -0800, 
Ben Woodard <ben@zork.net> wrote:
>Wouldn't a better way to fix this potential problem to add:
>...
>That way each and every ia64_sal_get_state_info() has a corresponding
>ia64_sal_clear_state_info().

The idea is right, the patch needed a bit of cleaning up.
Bjorn/DavidM, please apply, the patch fits both 2.4 and 2.6 (with
offsets).  Credit to Ben Woodard <ben@zork.net>.

Avoid double clear of CMC/CPE records.

--- linux/arch/ia64/kernel/salinfo.c	Wed Dec 24 17:16:12 2003
+++ linux/arch/ia64/kernel/salinfo.c	Wed Dec 24 17:15:08 2003
@@ -356,6 +356,8 @@
 {
 	struct salinfo_data *data = context;
 	data->log_size = ia64_sal_get_state_info(data->type, (u64 *) data->log_buffer);
+	if (data->type = SAL_INFO_TYPE_CPE || data->type = SAL_INFO_TYPE_CMC)
+		ia64_sal_clear_state_info(data->type);
 }
 
 static void
@@ -448,8 +450,11 @@
 		data->saved_num = 0;
 		spin_unlock_irqrestore(&data_saved_lock, flags);
 	}
-	call_on_cpu(cpu, salinfo_log_clear_cpu, data);
-
+	/* ia64_mca_log_sal_error_record or salinfo_log_read_cpu already cleared
+	 * CPE and CMC errors
+	 */
+	if (data->type != SAL_INFO_TYPE_CPE && data->type != SAL_INFO_TYPE_CMC)
+		call_on_cpu(cpu, salinfo_log_clear_cpu, data);
 	/* clearing a record may make a new record visible */
 	salinfo_log_new_read(cpu, data);
 	if (data->state = STATE_LOG_RECORD &&

