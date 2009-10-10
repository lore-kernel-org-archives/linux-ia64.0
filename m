From: Roel Kluin <roel.kluin@gmail.com>
Date: Sat, 10 Oct 2009 20:21:59 +0000
Subject: [PATCH] SN: unsigned cannot be less than 0 in sn_hwperf_ioctl()
Message-Id: <4AD0ECE7.4010406@gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

struct sn_hwperf_ioctl_args member arg (u64) cannot be less than 0.

Signed-off-by: Roel Kluin <roel.kluin@gmail.com>
---
// vi arch/ia64/include/asm/sn/sn2/sn_hwperf.h +73
struct sn_hwperf_ioctl_args {
        u64 arg;		/* argument, usually an object id */
        u64 sz;                 /* size of transfer */
        void *ptr;              /* pointer to source/target */
        u32 v0;			/* second return value */
};

diff --git a/arch/ia64/sn/kernel/sn2/sn_hwperf.c b/arch/ia64/sn/kernel/sn2/sn_hwperf.c
index 4c7e747..55ac3c4 100644
--- a/arch/ia64/sn/kernel/sn2/sn_hwperf.c
+++ b/arch/ia64/sn/kernel/sn2/sn_hwperf.c
@@ -786,17 +786,18 @@ sn_hwperf_ioctl(struct inode *in, struct file *fp, u32 op, unsigned long arg)
 		break;
 
 	case SN_HWPERF_GET_OBJ_NODE:
-		if (a.sz != sizeof(u64) || a.arg < 0) {
+		i = a.arg;
+		if (a.sz != sizeof(u64) || i < 0) {
 			r = -EINVAL;
 			goto error;
 		}
 		if ((r = sn_hwperf_enum_objects(&nobj, &objs)) = 0) {
-			if (a.arg >= nobj) {
+			if (i >= nobj) {
 				r = -EINVAL;
 				vfree(objs);
 				goto error;
 			}
-			if (objs[(i = a.arg)].id != a.arg) {
+			if (objs[i].id != a.arg) {
 				for (i = 0; i < nobj; i++) {
 					if (objs[i].id = a.arg)
 						break;
