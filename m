From: Keith Owens <kaos@sgi.com>
Date: Wed, 26 Nov 2003 00:56:30 +0000
Subject: [patch] 2.4.23-rc2 salinfo.c
Message-Id: <marc-linux-ia64-106980836603517@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Make salinfo.c more compatible with 2.6.  This is the 2.4 bit of
http://marc.theaimsgroup.com/?l=linux-ia64&m6974968032730&w=2

Use standard macro to get proc_dir_entry from inode.
Replace suser() with capable(CAP_SYS_ADMIN).

Index: 23-rc2.2/arch/ia64/kernel/salinfo.c
--- 23-rc2.2/arch/ia64/kernel/salinfo.c Tue, 18 Nov 2003 16:26:06 +1100 kaos (linux-2.4/K/g/22_salinfo.c 1.1.1.1.1.4 644)
+++ 23-rc2.2(w)/arch/ia64/kernel/salinfo.c Wed, 26 Nov 2003 11:45:52 +1100 kaos (linux-2.4/K/g/22_salinfo.c 1.1.1.1.1.4 644)
@@ -235,7 +235,7 @@ salinfo_log_wakeup(int type, u8 *buffer,
 static int
 salinfo_event_open(struct inode *inode, struct file *file)
 {
-	if (!suser())
+	if (!capable(CAP_SYS_ADMIN))
 		return -EPERM;
 	return 0;
 }
@@ -244,7 +244,7 @@ static ssize_t
 salinfo_event_read(struct file *file, char *buffer, size_t count, loff_t *ppos)
 {
 	struct inode *inode = file->f_dentry->d_inode;
-	struct proc_dir_entry *entry = (struct proc_dir_entry *) inode->u.generic_ip;
+	struct proc_dir_entry *entry = PDE(inode);
 	struct salinfo_data *data = entry->data;
 	char cmd[32];
 	size_t size;
@@ -298,10 +298,10 @@ static struct file_operations salinfo_ev
 static int
 salinfo_log_open(struct inode *inode, struct file *file)
 {
-	struct proc_dir_entry *entry = (struct proc_dir_entry *) inode->u.generic_ip;
+	struct proc_dir_entry *entry = PDE(inode);
 	struct salinfo_data *data = entry->data;
 
-	if (!suser())
+	if (!capable(CAP_SYS_ADMIN))
 		return -EPERM;
 
 	spin_lock(&data_lock);
@@ -324,7 +324,7 @@ salinfo_log_open(struct inode *inode, st
 static int
 salinfo_log_release(struct inode *inode, struct file *file)
 {
-	struct proc_dir_entry *entry = (struct proc_dir_entry *) inode->u.generic_ip;
+	struct proc_dir_entry *entry = PDE(inode);
 	struct salinfo_data *data = entry->data;
 
 	if (data->state = STATE_NO_DATA) {
@@ -395,7 +395,7 @@ static ssize_t
 salinfo_log_read(struct file *file, char *buffer, size_t count, loff_t *ppos)
 {
 	struct inode *inode = file->f_dentry->d_inode;
-	struct proc_dir_entry *entry = (struct proc_dir_entry *) inode->u.generic_ip;
+	struct proc_dir_entry *entry = PDE(inode);
 	struct salinfo_data *data = entry->data;
 	void *saldata;
 	size_t size;
@@ -462,7 +462,7 @@ static ssize_t
 salinfo_log_write(struct file *file, const char *buffer, size_t count, loff_t *ppos)
 {
 	struct inode *inode = file->f_dentry->d_inode;
-	struct proc_dir_entry *entry = (struct proc_dir_entry *) inode->u.generic_ip;
+	struct proc_dir_entry *entry = PDE(inode);
 	struct salinfo_data *data = entry->data;
 	char cmd[32];
 	size_t size;

