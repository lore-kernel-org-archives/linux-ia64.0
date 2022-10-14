From: Sergey Shtylyov <s.shtylyov@omp.ru>
Date: Fri, 14 Oct 2022 21:22:27 +0000
Subject: [PATCH 05/13] ia64: ptrace: user_regset_copyin_ignore() always returns 0
Message-Id: <20221014212235.10770-6-s.shtylyov@omp.ru>
List-Id: <linux-ia64.vger.kernel.org>
References: <20221014212235.10770-1-s.shtylyov@omp.ru>
In-Reply-To: <20221014212235.10770-1-s.shtylyov@omp.ru>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Oleg Nesterov <oleg@redhat.com>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org
Cc: Andrew Morton <akpm@linux-foundation.org>

user_regset_copyin_ignore() always returns 0, so checking its result seems
pointless -- don't do this anymore...

Signed-off-by: Sergey Shtylyov <s.shtylyov@omp.ru>
---
 arch/ia64/kernel/ptrace.c | 20 +++++++++-----------
 1 file changed, 9 insertions(+), 11 deletions(-)

diff --git a/arch/ia64/kernel/ptrace.c b/arch/ia64/kernel/ptrace.c
index ab8aeb34d1d9..4c41912c550f 100644
--- a/arch/ia64/kernel/ptrace.c
+++ b/arch/ia64/kernel/ptrace.c
@@ -1481,12 +1481,10 @@ static void do_gpregs_set(struct unw_frame_info *info, void *arg)
 		return;
 	/* Skip r0 */
 	if (dst->pos < ELF_GR_OFFSET(1)) {
-		dst->ret = user_regset_copyin_ignore(&dst->pos, &dst->count,
-						       &dst->u.set.kbuf,
-						       &dst->u.set.ubuf,
-						       0, ELF_GR_OFFSET(1));
-		if (dst->ret)
-			return;
+		user_regset_copyin_ignore(&dst->pos, &dst->count,
+					  &dst->u.set.kbuf, &dst->u.set.ubuf,
+					  0, ELF_GR_OFFSET(1));
+		dst->ret = 0;
 	}
 
 	while (dst->count && dst->pos < ELF_AR_END_OFFSET) {
@@ -1560,11 +1558,11 @@ static void do_fpregs_set(struct unw_frame_info *info, void *arg)
 
 	/* Skip pos 0 and 1 */
 	if (dst->count > 0 && dst->pos < ELF_FP_OFFSET(2)) {
-		dst->ret = user_regset_copyin_ignore(&dst->pos, &dst->count,
-						       &dst->u.set.kbuf,
-						       &dst->u.set.ubuf,
-						       0, ELF_FP_OFFSET(2));
-		if (dst->count = 0 || dst->ret)
+		user_regset_copyin_ignore(&dst->pos, &dst->count,
+					  &dst->u.set.kbuf, &dst->u.set.ubuf,
+					  0, ELF_FP_OFFSET(2));
+		dst->ret = 0;
+		if (dst->count = 0)
 			return;
 	}
 
-- 
2.26.3
