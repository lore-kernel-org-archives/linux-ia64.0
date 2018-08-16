From: Rasmus Villemoes <linux@rasmusvillemoes.dk>
Date: Thu, 16 Aug 2018 11:42:02 +0000
Subject: [PATCH] ia64/sn/hwperf: check seq_open return value to avoid NULL deref
Message-Id: <20180816114202.7094-1-linux@rasmusvillemoes.dk>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>
Cc: Rasmus Villemoes <linux@rasmusvillemoes.dk>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

This code should check the return value of seq_open(); if it failed,
file->private_data is NULL. But in that case we then need to dispose of
objbuf to prevent a resource leak.

Signed-off-by: Rasmus Villemoes <linux@rasmusvillemoes.dk>
---
 arch/ia64/sn/kernel/sn2/sn_hwperf.c | 8 ++++++--
 1 file changed, 6 insertions(+), 2 deletions(-)

diff --git a/arch/ia64/sn/kernel/sn2/sn_hwperf.c b/arch/ia64/sn/kernel/sn2/sn_hwperf.c
index 55febd65911a..9e36f0b7d9ae 100644
--- a/arch/ia64/sn/kernel/sn2/sn_hwperf.c
+++ b/arch/ia64/sn/kernel/sn2/sn_hwperf.c
@@ -947,8 +947,12 @@ int sn_topology_open(struct inode *inode, struct file *file)
 
 	if ((e = sn_hwperf_enum_objects(&nobj, &objbuf)) = 0) {
 		e = seq_open(file, &sn_topology_seq_ops);
-		seq = file->private_data;
-		seq->private = objbuf;
+		if (e) {
+			vfree(objbuf);
+		} else {
+			seq = file->private_data;
+			seq->private = objbuf;
+		}
 	}
 
 	return e;
-- 
2.16.4
