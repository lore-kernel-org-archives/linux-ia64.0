From: Frederic Weisbecker <fweisbec@gmail.com>
Date: Wed, 19 May 2010 17:24:15 +0000
Subject: [PATCH 8/8] ia64: Use unlocked_ioctl from perfmon
Message-Id: <1274289855-10001-9-git-send-regression-fweisbec@gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1274289855-10001-1-git-send-regression-fweisbec@gmail.com>
In-Reply-To: <1274289855-10001-1-git-send-regression-fweisbec@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Ingo Molnar <mingo@elte.hu>
Cc: LKML <linux-kernel@vger.kernel.org>, Frederic Weisbecker <fweisbec@gmail.com>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, IA64 <linux-ia64@vger.kernel.org>, Thomas Gleixner <tglx@linutronix.de>, John Kacur <jkacur@redhat.com>, Arnd Bergmann <arnd@arndb.de>

pfm_ioctl() obviously doesn't need the bkl just to print a
message.

Signed-off-by: Frederic Weisbecker <fweisbec@gmail.com>
Cc: Tony Luck <tony.luck@intel.com>
Cc: Fenghua Yu <fenghua.yu@intel.com>
Cc: IA64 <linux-ia64@vger.kernel.org>
Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: John Kacur <jkacur@redhat.com>
Cc: Arnd Bergmann <arnd@arndb.de>
---
 arch/ia64/kernel/perfmon.c |   22 +++++++++++-----------
 1 files changed, 11 insertions(+), 11 deletions(-)

diff --git a/arch/ia64/kernel/perfmon.c b/arch/ia64/kernel/perfmon.c
index ab985f7..7443290 100644
--- a/arch/ia64/kernel/perfmon.c
+++ b/arch/ia64/kernel/perfmon.c
@@ -1696,8 +1696,8 @@ pfm_poll(struct file *filp, poll_table * wait)
 	return mask;
 }
 
-static int
-pfm_ioctl(struct inode *inode, struct file *file, unsigned int cmd, unsigned long arg)
+static long
+pfm_ioctl(struct file *file, unsigned int cmd, unsigned long arg)
 {
 	DPRINT(("pfm_ioctl called\n"));
 	return -EINVAL;
@@ -2174,15 +2174,15 @@ pfm_no_open(struct inode *irrelevant, struct file *dontcare)
 
 
 static const struct file_operations pfm_file_ops = {
-	.llseek   = no_llseek,
-	.read     = pfm_read,
-	.write    = pfm_write,
-	.poll     = pfm_poll,
-	.ioctl    = pfm_ioctl,
-	.open     = pfm_no_open,	/* special open code to disallow open via /proc */
-	.fasync   = pfm_fasync,
-	.release  = pfm_close,
-	.flush	  = pfm_flush
+	.llseek		= no_llseek,
+	.read		= pfm_read,
+	.write		= pfm_write,
+	.poll		= pfm_poll,
+	.unlocked_ioctl = pfm_ioctl,
+	.open		= pfm_no_open,	/* special open code to disallow open via /proc */
+	.fasync		= pfm_fasync,
+	.release	= pfm_close,
+	.flush		= pfm_flush
 };
 
 static int
-- 
1.6.2.3

