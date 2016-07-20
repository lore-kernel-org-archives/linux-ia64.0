From: Kees Cook <keescook@chromium.org>
Date: Wed, 20 Jul 2016 20:26:57 +0000
Subject: [PATCH v4 02/12] mm: Implement stack frame object validation
Message-Id: <1469046427-12696-3-git-send-email-keescook@chromium.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <1469046427-12696-1-git-send-email-keescook@chromium.org>
In-Reply-To: <1469046427-12696-1-git-send-email-keescook@chromium.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: kernel-hardening@lists.openwall.com
Cc: Kees Cook <keescook@chromium.org>, Laura Abbott <labbott@fedoraproject.org>, Balbir Singh <bsingharora@gmail.com>, Daniel Micay <danielmicay@gmail.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Rik van Riel <riel@redhat.com>, Casey Schaufler <casey@schaufler-ca.com>, PaX Team <pageexec@freemail.hu>, Brad Spengler <spender@grsecurity.net>, Russell King <linux@armlinux.org.uk>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Michael Ellerman <mpe@ellerman.id.au>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, "David S. Miller" <davem@davemloft.net>, x86@kernel.org, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, Borislav Petkov <bp@suse.de>, Mathias Krause <minipli@googlemail.com>, Jan Kara <jack@suse.cz>, Vitaly Wool <vitalywool@gmail.com>, Andrea Arcangeli <aarcange@redhat.com>, Dmitry Vyukov <dvyukov@google.com>, linux-arm-kernel@lists.infradead.org, linux-ia64@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, sparclinux@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

This creates per-architecture function arch_within_stack_frames() that
should validate if a given object is contained by a kernel stack frame.
Initial implementation is on x86.

This is based on code from PaX.

Signed-off-by: Kees Cook <keescook@chromium.org>
---
 arch/Kconfig                       |  9 ++++++++
 arch/x86/Kconfig                   |  1 +
 arch/x86/include/asm/thread_info.h | 44 ++++++++++++++++++++++++++++++++++++++
 include/linux/thread_info.h        |  9 ++++++++
 4 files changed, 63 insertions(+)

diff --git a/arch/Kconfig b/arch/Kconfig
index d794384a0404..5e2776562035 100644
--- a/arch/Kconfig
+++ b/arch/Kconfig
@@ -424,6 +424,15 @@ config CC_STACKPROTECTOR_STRONG
 
 endchoice
 
+config HAVE_ARCH_WITHIN_STACK_FRAMES
+	bool
+	help
+	  An architecture should select this if it can walk the kernel stack
+	  frames to determine if an object is part of either the arguments
+	  or local variables (i.e. that it excludes saved return addresses,
+	  and similar) by implementing an inline arch_within_stack_frames(),
+	  which is used by CONFIG_HARDENED_USERCOPY.
+
 config HAVE_CONTEXT_TRACKING
 	bool
 	help
diff --git a/arch/x86/Kconfig b/arch/x86/Kconfig
index 0a7b885964ba..4407f596b72c 100644
--- a/arch/x86/Kconfig
+++ b/arch/x86/Kconfig
@@ -91,6 +91,7 @@ config X86
 	select HAVE_ARCH_SOFT_DIRTY		if X86_64
 	select HAVE_ARCH_TRACEHOOK
 	select HAVE_ARCH_TRANSPARENT_HUGEPAGE
+	select HAVE_ARCH_WITHIN_STACK_FRAMES
 	select HAVE_EBPF_JIT			if X86_64
 	select HAVE_CC_STACKPROTECTOR
 	select HAVE_CMPXCHG_DOUBLE
diff --git a/arch/x86/include/asm/thread_info.h b/arch/x86/include/asm/thread_info.h
index 30c133ac05cd..ab386f1336f2 100644
--- a/arch/x86/include/asm/thread_info.h
+++ b/arch/x86/include/asm/thread_info.h
@@ -180,6 +180,50 @@ static inline unsigned long current_stack_pointer(void)
 	return sp;
 }
 
+/*
+ * Walks up the stack frames to make sure that the specified object is
+ * entirely contained by a single stack frame.
+ *
+ * Returns:
+ *		 1 if within a frame
+ *		-1 if placed across a frame boundary (or outside stack)
+ *		 0 unable to determine (no frame pointers, etc)
+ */
+static inline int arch_within_stack_frames(const void * const stack,
+					   const void * const stackend,
+					   const void *obj, unsigned long len)
+{
+#if defined(CONFIG_FRAME_POINTER)
+	const void *frame = NULL;
+	const void *oldframe;
+
+	oldframe = __builtin_frame_address(1);
+	if (oldframe)
+		frame = __builtin_frame_address(2);
+	/*
+	 * low ----------------------------------------------> high
+	 * [saved bp][saved ip][args][local vars][saved bp][saved ip]
+	 *                     ^----------------^
+	 *               allow copies only within here
+	 */
+	while (stack <= frame && frame < stackend) {
+		/*
+		 * If obj + len extends past the last frame, this
+		 * check won't pass and the next frame will be 0,
+		 * causing us to bail out and correctly report
+		 * the copy as invalid.
+		 */
+		if (obj + len <= frame)
+			return obj >= oldframe + 2 * sizeof(void *) ? 1 : -1;
+		oldframe = frame;
+		frame = *(const void * const *)frame;
+	}
+	return -1;
+#else
+	return 0;
+#endif
+}
+
 #else /* !__ASSEMBLY__ */
 
 #ifdef CONFIG_X86_64
diff --git a/include/linux/thread_info.h b/include/linux/thread_info.h
index b4c2a485b28a..3d5c80b4391d 100644
--- a/include/linux/thread_info.h
+++ b/include/linux/thread_info.h
@@ -146,6 +146,15 @@ static inline bool test_and_clear_restore_sigmask(void)
 #error "no set_restore_sigmask() provided and default one won't work"
 #endif
 
+#ifndef CONFIG_HAVE_ARCH_WITHIN_STACK_FRAMES
+static inline int arch_within_stack_frames(const void * const stack,
+					   const void * const stackend,
+					   const void *obj, unsigned long len)
+{
+	return 0;
+}
+#endif
+
 #endif	/* __KERNEL__ */
 
 #endif /* _LINUX_THREAD_INFO_H */
-- 
2.7.4

