From: Mathias Krause <minipli@googlemail.com>
Date: Fri, 10 Jun 2011 13:09:39 +0000
Subject: [PATCH] ia64, exec: remove redundant set_fs(USER_DS)
Message-Id: <1307711379-7526-1-git-send-email-minipli@googlemail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <BANLkTinv1teZEHMK0qymaVdcxPOErpqSyg@mail.gmail.com>
In-Reply-To: <BANLkTinv1teZEHMK0qymaVdcxPOErpqSyg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Tony Luck <tony.luck@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, Mathias Krause <minipli@googlemail.com>, Fenghua Yu <fenghua.yu@intel.com>

The address limit is already set in flush_old_exec() so this
set_fs(USER_DS) is redundant.

Signed-off-by: Mathias Krause <minipli@googlemail.com>
Cc: Fenghua Yu <fenghua.yu@intel.com>
---
 arch/ia64/include/asm/processor.h |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/arch/ia64/include/asm/processor.h b/arch/ia64/include/asm/processor.h
index 03afe79..b2d6051 100644
--- a/arch/ia64/include/asm/processor.h
+++ b/arch/ia64/include/asm/processor.h
@@ -309,7 +309,6 @@ struct thread_struct {
 }
 
 #define start_thread(regs,new_ip,new_sp) do {							\
-	set_fs(USER_DS);									\
 	regs->cr_ipsr = ((regs->cr_ipsr | (IA64_PSR_BITS_TO_SET | IA64_PSR_CPL))		\
 			 & ~(IA64_PSR_BITS_TO_CLEAR | IA64_PSR_RI | IA64_PSR_IS));		\
 	regs->cr_iip = new_ip;									\
-- 
1.5.6.5

