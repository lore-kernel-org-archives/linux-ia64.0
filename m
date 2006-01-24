From: Jack Steiner <steiner@sgi.com>
Date: Tue, 24 Jan 2006 22:32:11 +0000
Subject: [PATCH] - Scaling fix for simulatneous unaligned accesses
Message-Id: <20060124223210.GA6878@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Eliminate a hot shared cacheline that occurs if multiple cpus are
taking unaligned exceptions.

	Signed-off-by: Jack Steiner <steiner@sgi.com>


Index: linux/arch/ia64/kernel/unaligned.c
=================================--- linux.orig/arch/ia64/kernel/unaligned.c	2006-01-23 14:02:18.582928211 -0600
+++ linux/arch/ia64/kernel/unaligned.c	2006-01-24 16:02:26.266232267 -0600
@@ -1283,8 +1283,9 @@ within_logging_rate_limit (void)
 
 	if (jiffies - last_time > 5*HZ)
 		count = 0;
-	if (++count < 5) {
+	if (count < 5) {
 		last_time = jiffies;
+		count++;
 		return 1;
 	}
 	return 0;
