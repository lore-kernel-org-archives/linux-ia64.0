From: Michael Ellerman <michael@ellerman.id.au>
Date: Tue, 26 Jun 2007 01:48:51 +0000
Subject: [PATCH 2/3] Remove JPROBE_ENTRY()
Message-Id: <98c8ff25191ced991066092ffd4899526097da1e.1182822366.git.michael@ellerman.id.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <78935473b1f70c863ab0be7d6cf4bcb04922b20b.1182822366.git.michael@ellerman.id.au>
In-Reply-To: <78935473b1f70c863ab0be7d6cf4bcb04922b20b.1182822366.git.michael@ellerman.id.au>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org
Cc: linuxppc-dev@ozlabs.org, linux-ia64@vger.kernel.org, linux-arch@vger.kernel.org, Andrew Morton <akpm@osdl.org>, Christoph Hellwig <hch@lst.de>, anil.s.keshavamurthy@intel.com, ananth@in.ibm.com

AFAICT now that jprobe.entry is a void *, JPROBE_ENTRY doesn't do
anything useful - so remove it ..

I've left a do-nothing version so that out-of-tree jprobes code will still
compile without modifications.

Signed-off-by: Michael Ellerman <michael@ellerman.id.au>
---
 Documentation/kprobes.txt     |    8 +-------
 include/asm-i386/kprobes.h    |    1 -
 include/asm-ia64/kprobes.h    |    2 --
 include/asm-powerpc/kprobes.h |    2 --
 include/asm-s390/kprobes.h    |    2 --
 include/asm-sparc64/kprobes.h |    1 -
 include/asm-x86_64/kprobes.h  |    1 -
 include/linux/kprobes.h       |    3 +++
 net/dccp/probe.c              |    2 +-
 net/ipv4/tcp_probe.c          |    2 +-
 10 files changed, 6 insertions(+), 18 deletions(-)

diff --git a/Documentation/kprobes.txt b/Documentation/kprobes.txt
index da5404a..cb12ae1 100644
--- a/Documentation/kprobes.txt
+++ b/Documentation/kprobes.txt
@@ -247,12 +247,6 @@ control to Kprobes.)  If the probed function is declared asmlinkage,
 fastcall, or anything else that affects how args are passed, the
 handler's declaration must match.
 
-NOTE: A macro JPROBE_ENTRY is provided to handle architecture-specific
-aliasing of jp->entry. In the interest of portability, it is advised
-to use:
-
-	jp->entry = JPROBE_ENTRY(handler);
-
 register_jprobe() returns 0 on success, or a negative errno otherwise.
 
 4.3 register_kretprobe
@@ -518,7 +512,7 @@ long jdo_fork(unsigned long clone_flags, unsigned long stack_start,
 }
 
 static struct jprobe my_jprobe = {
-	.entry = JPROBE_ENTRY(jdo_fork)
+	.entry = jdo_fork
 };
 
 static int __init jprobe_init(void)
diff --git a/include/asm-i386/kprobes.h b/include/asm-i386/kprobes.h
index 8774d06..06f7303 100644
--- a/include/asm-i386/kprobes.h
+++ b/include/asm-i386/kprobes.h
@@ -42,7 +42,6 @@ typedef u8 kprobe_opcode_t;
 	? (MAX_STACK_SIZE) \
 	: (((unsigned long)current_thread_info()) + THREAD_SIZE - (ADDR)))
 
-#define JPROBE_ENTRY(pentry)	(kprobe_opcode_t *)pentry
 #define ARCH_SUPPORTS_KRETPROBES
 #define  ARCH_INACTIVE_KPROBE_COUNT 0
 #define flush_insn_slot(p)	do { } while (0)
diff --git a/include/asm-ia64/kprobes.h b/include/asm-ia64/kprobes.h
index 6382e52..067d9de 100644
--- a/include/asm-ia64/kprobes.h
+++ b/include/asm-ia64/kprobes.h
@@ -82,8 +82,6 @@ struct kprobe_ctlblk {
 	struct prev_kprobe prev_kprobe[ARCH_PREV_KPROBE_SZ];
 };
 
-#define JPROBE_ENTRY(pentry)	(kprobe_opcode_t *)pentry
-
 #define ARCH_SUPPORTS_KRETPROBES
 #define  ARCH_INACTIVE_KPROBE_COUNT 1
 
diff --git a/include/asm-powerpc/kprobes.h b/include/asm-powerpc/kprobes.h
index b0e40ff..3481ade 100644
--- a/include/asm-powerpc/kprobes.h
+++ b/include/asm-powerpc/kprobes.h
@@ -73,12 +73,10 @@ typedef unsigned int kprobe_opcode_t;
 	}								\
 }
 
-#define JPROBE_ENTRY(pentry)	(kprobe_opcode_t *)((func_descr_t *)pentry)
 #define is_trap(instr)	(IS_TW(instr) || IS_TD(instr) || \
 			IS_TWI(instr) || IS_TDI(instr))
 #else
 /* Use stock kprobe_lookup_name since ppc32 doesn't use function descriptors */
-#define JPROBE_ENTRY(pentry)	(kprobe_opcode_t *)(pentry)
 #define is_trap(instr)	(IS_TW(instr) || IS_TWI(instr))
 #endif
 
diff --git a/include/asm-s390/kprobes.h b/include/asm-s390/kprobes.h
index 830fe4c..340ba10 100644
--- a/include/asm-s390/kprobes.h
+++ b/include/asm-s390/kprobes.h
@@ -46,8 +46,6 @@ typedef u16 kprobe_opcode_t;
 	? (MAX_STACK_SIZE) \
 	: (((unsigned long)current_thread_info()) + THREAD_SIZE - (ADDR)))
 
-#define JPROBE_ENTRY(pentry) (kprobe_opcode_t *)(pentry)
-
 #define ARCH_SUPPORTS_KRETPROBES
 #define ARCH_INACTIVE_KPROBE_COUNT 0
 
diff --git a/include/asm-sparc64/kprobes.h b/include/asm-sparc64/kprobes.h
index a331b7b..7f6774d 100644
--- a/include/asm-sparc64/kprobes.h
+++ b/include/asm-sparc64/kprobes.h
@@ -10,7 +10,6 @@ typedef u32 kprobe_opcode_t;
 #define BREAKPOINT_INSTRUCTION_2 0x91d02071 /* ta 0x71 */
 #define MAX_INSN_SIZE 2
 
-#define JPROBE_ENTRY(pentry)	(kprobe_opcode_t *)pentry
 #define arch_remove_kprobe(p)	do {} while (0)
 #define  ARCH_INACTIVE_KPROBE_COUNT 0
 
diff --git a/include/asm-x86_64/kprobes.h b/include/asm-x86_64/kprobes.h
index cf53178..7db8254 100644
--- a/include/asm-x86_64/kprobes.h
+++ b/include/asm-x86_64/kprobes.h
@@ -41,7 +41,6 @@ typedef u8 kprobe_opcode_t;
 	? (MAX_STACK_SIZE) \
 	: (((unsigned long)current_thread_info()) + THREAD_SIZE - (ADDR)))
 
-#define JPROBE_ENTRY(pentry)	(kprobe_opcode_t *)pentry
 #define ARCH_SUPPORTS_KRETPROBES
 #define  ARCH_INACTIVE_KPROBE_COUNT 1
 
diff --git a/include/linux/kprobes.h b/include/linux/kprobes.h
index f4e53b7..bd89285 100644
--- a/include/linux/kprobes.h
+++ b/include/linux/kprobes.h
@@ -119,6 +119,9 @@ struct jprobe {
 	void *entry;	/* probe handling code to jump to */
 };
 
+/* For backward compatibility with old code using JPROBE_ENTRY() */
+#define JPROBE_ENTRY(handler)	(handler)
+
 DECLARE_PER_CPU(struct kprobe *, current_kprobe);
 DECLARE_PER_CPU(struct kprobe_ctlblk, kprobe_ctlblk);
 
diff --git a/net/dccp/probe.c b/net/dccp/probe.c
index 43a3adb..bae10b0 100644
--- a/net/dccp/probe.c
+++ b/net/dccp/probe.c
@@ -112,7 +112,7 @@ static struct jprobe dccp_send_probe = {
 	.kp	= {
 		.symbol_name = "dccp_sendmsg",
 	},
-	.entry	= JPROBE_ENTRY(jdccp_sendmsg),
+	.entry	= jdccp_sendmsg,
 };
 
 static int dccpprobe_open(struct inode *inode, struct file *file)
diff --git a/net/ipv4/tcp_probe.c b/net/ipv4/tcp_probe.c
index d9323df..4a7ef10 100644
--- a/net/ipv4/tcp_probe.c
+++ b/net/ipv4/tcp_probe.c
@@ -115,7 +115,7 @@ static struct jprobe tcp_probe = {
 	.kp = {
 		.symbol_name	= "tcp_rcv_established",
 	},
-	.entry	= JPROBE_ENTRY(jtcp_rcv_established),
+	.entry	= jtcp_rcv_established,
 };
 
 
-- 
1.5.1.3.g7a33b

