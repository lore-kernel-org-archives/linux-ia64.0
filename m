From: Anant Thazhemadam <anant.thazhemadam@gmail.com>
Date: Mon, 31 Aug 2020 09:29:46 +0000
Subject: [PATCH] arch: ia64 - Update put_filp to fput
Message-Id: <20200831091747.9305-1-anant.thazhemadam@gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: 
Cc: anant.thazhemadam@gmail.com, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, "Gustavo A. R. Silva" <gustavoars@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Daniel Jordan <daniel.m.jordan@oracle.com>, afzal mohammed <afzal.mohd.ma@gmail.com>, Michel Lespinasse <walken@google.com>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

The function `put_filp`, (along with almost all references of it) seems to
have been deprecated and exist no more, and neither the prototype nor
the function definition seem to be a part of the main kernel tree anymore. 
It has been recommended that `fput` be used instead, so it felt like it 
was about time this was updated too

Signed-off-by: Anant Thazhemadam <anant.thazhemadam@gmail.com>
---
 arch/ia64/kernel/perfmon.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/arch/ia64/kernel/perfmon.c b/arch/ia64/kernel/perfmon.c
index 0dc3611e7971..91349e38b9be 100644
--- a/arch/ia64/kernel/perfmon.c
+++ b/arch/ia64/kernel/perfmon.c
@@ -2644,7 +2644,7 @@ pfm_context_create(pfm_context_t *ctx, void *arg, int count, struct pt_regs *reg
 
 buffer_error:
 	path = filp->f_path;
-	put_filp(filp);
+	fput(filp);
 	path_put(&path);
 
 	if (ctx->ctx_buf_fmt) {
-- 
2.25.1
