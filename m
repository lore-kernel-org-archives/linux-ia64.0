From: dann frazier <dannf@hp.com>
Date: Fri, 27 Jan 2006 22:21:06 +0000
Subject: salinfo incorrectly returning -ENOMEM
Message-Id: <1138400466.19287.24.camel@krebs.dannf>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

salinfo_decode will silently exit occasionally due to a failed open
of /proc/sal/XXX/data.  This is because the kernel is returning -ENOMEM
after attempting to vmalloc a buffer of size  
ia64_sal_get_state_info_size(data->type).

However, on my system ia64_sal_get_state_info_size is returning 0, in
which case I'd think a NULL vmalloc() result is correct.  

This patch assumes, of course, that 0 is a reasonable return value from
ia64_sal_get_state_info_size().

Signed-off-by: dann frazier <dannf@hp.com>

--- linux-2.6.16-rc1/arch/ia64/kernel/salinfo.c.orig	2006-01-27 14:44:20.000000000 -0700
+++ linux-2.6.16-rc1/arch/ia64/kernel/salinfo.c	2006-01-27 14:45:39.000000000 -0700
@@ -358,6 +358,7 @@ salinfo_log_open(struct inode *inode, st
 {
 	struct proc_dir_entry *entry = PDE(inode);
 	struct salinfo_data *data = entry->data;
+	u64 size;
 
 	if (!capable(CAP_SYS_ADMIN))
 		return -EPERM;
@@ -370,8 +371,9 @@ salinfo_log_open(struct inode *inode, st
 	data->open = 1;
 	spin_unlock(&data_lock);
 
-	if (data->state = STATE_NO_DATA &&
-	    !(data->log_buffer = vmalloc(ia64_sal_get_state_info_size(data->type)))) {
+	size = ia64_sal_get_state_info_size(data->type);
+	if (data->state = STATE_NO_DATA && size &&
+	    !(data->log_buffer = vmalloc(size))) {
 		data->open = 0;
 		return -ENOMEM;
 	}


