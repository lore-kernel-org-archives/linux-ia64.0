From: akpm@linux-foundation.org
Date: Tue, 15 Nov 2011 22:53:44 +0000
Subject: [patch 1/1] ia64, exec: remove redundant set_fs(USER_DS)
Message-Id: <201111152253.pAFMriW2014723@wpaz9.hot.corp.google.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

From: Mathias Krause <minipli@googlemail.com>
Subject: ia64, exec: remove redundant set_fs(USER_DS)

The address limit is already set in flush_old_exec() so this
set_fs(USER_DS) is redundant.

Signed-off-by: Mathias Krause <minipli@googlemail.com>
Cc: Fenghua Yu <fenghua.yu@intel.com>
Cc: "Luck, Tony" <tony.luck@intel.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 arch/ia64/include/asm/processor.h |    1 -
 1 file changed, 1 deletion(-)

diff -puN arch/ia64/include/asm/processor.h~ia64-exec-remove-redundant-set_fsuser_ds arch/ia64/include/asm/processor.h
--- a/arch/ia64/include/asm/processor.h~ia64-exec-remove-redundant-set_fsuser_ds
+++ a/arch/ia64/include/asm/processor.h
@@ -309,7 +309,6 @@ struct thread_struct {
 }
 
 #define start_thread(regs,new_ip,new_sp) do {							\
-	set_fs(USER_DS);									\
 	regs->cr_ipsr = ((regs->cr_ipsr | (IA64_PSR_BITS_TO_SET | IA64_PSR_CPL))		\
 			 & ~(IA64_PSR_BITS_TO_CLEAR | IA64_PSR_RI | IA64_PSR_IS));		\
 	regs->cr_iip = new_ip;									\
_
