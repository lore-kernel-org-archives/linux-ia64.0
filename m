From: Roland McGrath <roland@redhat.com>
Date: Wed, 19 Mar 2008 21:20:01 +0000
Subject: [PATCH 5/8] sparc64 ptrace: forced_successful_syscall_return()
Message-Id: <20080319212001.2DB8526F995@magilla.localdomain>
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
 include/asm-sparc64/ptrace.h |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/include/asm-sparc64/ptrace.h b/include/asm-sparc64/ptrace.h
index 6da1978..3f8826e 100644
--- a/include/asm-sparc64/ptrace.h
+++ b/include/asm-sparc64/ptrace.h
@@ -100,6 +100,8 @@ struct sparc_trapf {
 #define force_successful_syscall_return()	    \
 do {	current_thread_info()->syscall_noerror = 1; \
 } while (0)
+#define forced_successful_syscall_return()	\
+	(current_thread_info()->syscall_noerror != 0)
 #define user_mode(regs) (!((regs)->tstate & TSTATE_PRIV))
 #define instruction_pointer(regs) ((regs)->tpc)
 #define regs_return_value(regs) ((regs)->u_regs[UREG_I0])
