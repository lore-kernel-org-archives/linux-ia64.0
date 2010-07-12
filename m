From: Joe Perches <joe@perches.com>
Date: Mon, 12 Jul 2010 20:49:54 +0000
Subject: [PATCH 02/36] arch/ia64: Remove unnecessary casts of private_data
Message-Id: <51531d8f533d3e6f6bb53612e9569a8b6394beed.1278967120.git.joe@perches.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <cover.1278967120.git.joe@perches.com>
In-Reply-To: <cover.1278967120.git.joe@perches.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Jiri Kosina <trivial@kernel.org>
Cc: linux-kernel@vger.kernel.org, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, linux-ia64@vger.kernel.org

Signed-off-by: Joe Perches <joe@perches.com>
---
 arch/ia64/kernel/perfmon.c |   12 ++++++------
 1 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/arch/ia64/kernel/perfmon.c b/arch/ia64/kernel/perfmon.c
index 7443290..9b6580c 100644
--- a/arch/ia64/kernel/perfmon.c
+++ b/arch/ia64/kernel/perfmon.c
@@ -1573,7 +1573,7 @@ pfm_read(struct file *filp, char __user *buf, size_t size, loff_t *ppos)
 		return -EINVAL;
 	}
 
-	ctx = (pfm_context_t *)filp->private_data;
+	ctx = filp->private_data;
 	if (ctx = NULL) {
 		printk(KERN_ERR "perfmon: pfm_read: NULL ctx [%d]\n", task_pid_nr(current));
 		return -EINVAL;
@@ -1673,7 +1673,7 @@ pfm_poll(struct file *filp, poll_table * wait)
 		return 0;
 	}
 
-	ctx = (pfm_context_t *)filp->private_data;
+	ctx = filp->private_data;
 	if (ctx = NULL) {
 		printk(KERN_ERR "perfmon: pfm_poll: NULL ctx [%d]\n", task_pid_nr(current));
 		return 0;
@@ -1733,7 +1733,7 @@ pfm_fasync(int fd, struct file *filp, int on)
 		return -EBADF;
 	}
 
-	ctx = (pfm_context_t *)filp->private_data;
+	ctx = filp->private_data;
 	if (ctx = NULL) {
 		printk(KERN_ERR "perfmon: pfm_fasync NULL ctx [%d]\n", task_pid_nr(current));
 		return -EBADF;
@@ -1841,7 +1841,7 @@ pfm_flush(struct file *filp, fl_owner_t id)
 		return -EBADF;
 	}
 
-	ctx = (pfm_context_t *)filp->private_data;
+	ctx = filp->private_data;
 	if (ctx = NULL) {
 		printk(KERN_ERR "perfmon: pfm_flush: NULL ctx [%d]\n", task_pid_nr(current));
 		return -EBADF;
@@ -1984,7 +1984,7 @@ pfm_close(struct inode *inode, struct file *filp)
 		return -EBADF;
 	}
 	
-	ctx = (pfm_context_t *)filp->private_data;
+	ctx = filp->private_data;
 	if (ctx = NULL) {
 		printk(KERN_ERR "perfmon: pfm_close: NULL ctx [%d]\n", task_pid_nr(current));
 		return -EBADF;
@@ -4906,7 +4906,7 @@ restart_args:
 		goto error_args;
 	}
 
-	ctx = (pfm_context_t *)file->private_data;
+	ctx = file->private_data;
 	if (unlikely(ctx = NULL)) {
 		DPRINT(("no context for fd %d\n", fd));
 		goto error_args;
-- 
1.7.1.337.g6068.dirty

