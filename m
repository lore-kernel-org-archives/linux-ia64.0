From: SF Markus Elfring <elfring@users.sourceforge.net>
Date: Fri, 20 Oct 2017 16:14:11 +0000
Subject: [PATCH] ia64/kernel/ptrace: Use common error handling code in two functions
Message-Id: <48f0efa9-ae84-c338-3f07-1f39fc3ad6a6@users.sourceforge.net>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org, Fenghua Yu <fenghua.yu@intel.com>, Oleg Nesterov <oleg@redhat.com>, Tony Luck <tony.luck@intel.com>
Cc: LKML <linux-kernel@vger.kernel.org>, kernel-janitors@vger.kernel.org

From: Markus Elfring <elfring@users.sourceforge.net>
Date: Fri, 20 Oct 2017 18:00:52 +0200

* Add a jump target so that a bit of exception handling can be better
  reused at the end of these functions.

  This issue was detected by using the Coccinelle software.

* Adjust the indentation for six if statements.

Signed-off-by: Markus Elfring <elfring@users.sourceforge.net>
---
 arch/ia64/kernel/ptrace.c | 63 +++++++++++++++++++++++++----------------------
 1 file changed, 33 insertions(+), 30 deletions(-)

diff --git a/arch/ia64/kernel/ptrace.c b/arch/ia64/kernel/ptrace.c
index 3f8293378a83..447e3f353014 100644
--- a/arch/ia64/kernel/ptrace.c
+++ b/arch/ia64/kernel/ptrace.c
@@ -1537,11 +1537,10 @@ void do_gpregs_get(struct unw_frame_info *info, void *arg)
 			 (dst->pos + dst->count) : ELF_GR_OFFSET(16);
 		for (i = dst->pos; i < min_copy; i += sizeof(elf_greg_t),
 				index++)
-			if (access_elf_reg(dst->target, info, i,
-						&tmp[index], 0) < 0) {
-				dst->ret = -EIO;
-				return;
-			}
+			if (access_elf_reg(dst->target, info, i, &tmp[index], 0)
+			    < 0)
+				goto e_io;
+
 		dst->ret = user_regset_copyout(&dst->pos, &dst->count,
 				&dst->u.get.kbuf, &dst->u.get.ubuf, tmp,
 				ELF_GR_OFFSET(1), ELF_GR_OFFSET(16));
@@ -1566,11 +1565,10 @@ void do_gpregs_get(struct unw_frame_info *info, void *arg)
 			 (dst->pos + dst->count) : ELF_CR_IIP_OFFSET;
 		for (i = dst->pos; i < min_copy; i += sizeof(elf_greg_t),
 				index++)
-			if (access_elf_reg(dst->target, info, i,
-						&tmp[index], 0) < 0) {
-				dst->ret = -EIO;
-				return;
-			}
+			if (access_elf_reg(dst->target, info, i, &tmp[index], 0)
+			    < 0)
+				goto e_io;
+
 		dst->ret = user_regset_copyout(&dst->pos, &dst->count,
 				&dst->u.get.kbuf, &dst->u.get.ubuf, tmp,
 				ELF_NAT_OFFSET, ELF_CR_IIP_OFFSET);
@@ -1587,15 +1585,19 @@ void do_gpregs_get(struct unw_frame_info *info, void *arg)
 			 (dst->pos + dst->count) : ELF_AR_END_OFFSET;
 		for (i = dst->pos; i < min_copy; i += sizeof(elf_greg_t),
 				index++)
-			if (access_elf_reg(dst->target, info, i,
-						&tmp[index], 0) < 0) {
-				dst->ret = -EIO;
-				return;
-			}
+			if (access_elf_reg(dst->target, info, i, &tmp[index], 0)
+			    < 0)
+				goto e_io;
+
 		dst->ret = user_regset_copyout(&dst->pos, &dst->count,
 				&dst->u.get.kbuf, &dst->u.get.ubuf, tmp,
 				ELF_CR_IIP_OFFSET, ELF_AR_END_OFFSET);
 	}
+
+	return;
+
+e_io:
+	dst->ret = -EIO;
 }
 
 void do_gpregs_set(struct unw_frame_info *info, void *arg)
@@ -1628,11 +1630,10 @@ void do_gpregs_set(struct unw_frame_info *info, void *arg)
 		if (dst->ret)
 			return;
 		for ( ; i < dst->pos; i += sizeof(elf_greg_t), index++)
-			if (access_elf_reg(dst->target, info, i,
-						&tmp[index], 1) < 0) {
-				dst->ret = -EIO;
-				return;
-			}
+			if (access_elf_reg(dst->target, info, i, &tmp[index], 1)
+			    < 0)
+				goto e_io;
+
 		if (dst->count = 0)
 			return;
 	}
@@ -1657,11 +1658,10 @@ void do_gpregs_set(struct unw_frame_info *info, void *arg)
 		if (dst->ret)
 			return;
 		for (; i < dst->pos; i += sizeof(elf_greg_t), index++)
-			if (access_elf_reg(dst->target, info, i,
-						&tmp[index], 1) < 0) {
-				dst->ret = -EIO;
-				return;
-			}
+			if (access_elf_reg(dst->target, info, i, &tmp[index], 1)
+			    < 0)
+				goto e_io;
+
 		if (dst->count = 0)
 			return;
 	}
@@ -1678,12 +1678,15 @@ void do_gpregs_set(struct unw_frame_info *info, void *arg)
 		if (dst->ret)
 			return;
 		for ( ; i < dst->pos; i += sizeof(elf_greg_t), index++)
-			if (access_elf_reg(dst->target, info, i,
-						&tmp[index], 1) < 0) {
-				dst->ret = -EIO;
-				return;
-			}
+			if (access_elf_reg(dst->target, info, i, &tmp[index], 1)
+			    < 0)
+				goto e_io;
 	}
+
+	return;
+
+e_io:
+	dst->ret = -EIO;
 }
 
 #define ELF_FP_OFFSET(i)	(i * sizeof(elf_fpreg_t))
-- 
2.14.2

