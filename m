From: Wei Yongjun <weiyj.lk@gmail.com>
Date: Wed, 17 Oct 2012 15:09:49 +0000
Subject: [PATCH] [IA64] kprobes: remove unused variable in get_kprobe_inst()
Message-Id: <CAPgLHd8TVWxi__9pQzbSCBHq2fcQu1jk_2pn55V2EyLO88rUQA@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

From: Wei Yongjun <yongjun_wei@trendmicro.com.cn>

The variable template is initialized but never used
otherwise, so remove the unused variable.

dpatch engine is used to auto generate this patch.
(https://github.com/weiyj/dpatch)

Signed-off-by: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
---
 arch/ia64/kernel/kprobes.c | 3 ---
 1 file changed, 3 deletions(-)

diff --git a/arch/ia64/kernel/kprobes.c b/arch/ia64/kernel/kprobes.c
index 7026b29..ba4ad68 100644
--- a/arch/ia64/kernel/kprobes.c
+++ b/arch/ia64/kernel/kprobes.c
@@ -337,9 +337,6 @@ static void __kprobes get_kprobe_inst(bundle_t *bundle, uint slot,
 	       	unsigned long *kprobe_inst, uint *major_opcode)
 {
 	unsigned long kprobe_inst_p0, kprobe_inst_p1;
-	unsigned int template;
-
-	template = bundle->quad0.template;
 
 	switch (slot) {
 	  case 0:

