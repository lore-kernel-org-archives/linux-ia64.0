From: Roland McGrath <roland@redhat.com>
Date: Wed, 19 Mar 2008 21:19:36 +0000
Subject: [PATCH 4/8] powerpc ptrace: forced_successful_syscall_return()
Message-Id: <20080319211936.28E8B26F9A7@magilla.localdomain>
List-Id: <linux-ia64.vger.kernel.org>
References: <20080319211714.8B14226F995@magilla.localdomain>
In-Reply-To: Roland McGrath's message of  Wednesday, 19 March 2008 14:17:14 -0700 <20080319211714.8B14226F995@magilla.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org

Define the forced_successful_syscall_return() macro to
pair with our force_successful_syscall_return() definition.

Signed-off-by: Roland McGrath <roland@redhat.com>
---
 include/asm-powerpc/ptrace.h |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/include/asm-powerpc/ptrace.h b/include/asm-powerpc/ptrace.h
index 891d689..07dd6fe 100644
--- a/include/asm-powerpc/ptrace.h
+++ b/include/asm-powerpc/ptrace.h
@@ -93,6 +93,7 @@ extern unsigned long profile_pc(struct pt_regs *regs);
 	do { \
 		set_thread_flag(TIF_NOERROR); \
 	} while(0)
+#define forced_successful_syscall_return()   (test_thread_flag(TIF_NOERROR))
 
 struct task_struct;
 extern unsigned long ptrace_get_reg(struct task_struct *task, int regno);
