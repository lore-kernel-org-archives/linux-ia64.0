From: Arnd Bergmann <arnd@arndb.de>
Date: Sat, 03 Jul 2010 22:15:05 +0000
Subject: [PATCH 1/6] ia64/perfmon: convert to unlocked_ioctl
Message-Id: <1278195310-25590-2-git-send-email-arnd@arndb.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <1278195310-25590-1-git-send-email-arnd@arndb.de>
In-Reply-To: <1278195310-25590-1-git-send-email-arnd@arndb.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org
Cc: John Kacur <jkacur@redhat.com>, Frederic Weisbecker <fweisbec@gmail.com>, Arnd Bergmann <arnd@arndb.de>, Tony Luck <tony.luck@intel.com>, linux-ia64@vger.kernel.org

The ioctl function in this driver does not
do anything that requires the BKL, so make
it use unlocked_ioctl.

Signed-off-by: Arnd Bergmann <arnd@arndb.de>
Cc: Tony Luck <tony.luck@intel.com>
Cc: linux-ia64@vger.kernel.org
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
1.7.1

