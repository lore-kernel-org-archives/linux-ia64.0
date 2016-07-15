From: Kees Cook <keescook@chromium.org>
Date: Fri, 15 Jul 2016 21:44:17 +0000
Subject: [PATCH v3 03/11] x86/uaccess: Enable hardened usercopy
Message-Id: <1468619065-3222-4-git-send-email-keescook@chromium.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <1468619065-3222-1-git-send-email-keescook@chromium.org>
In-Reply-To: <1468619065-3222-1-git-send-email-keescook@chromium.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org
Cc: Kees Cook <keescook@chromium.org>, Balbir Singh <bsingharora@gmail.com>, Daniel Micay <danielmicay@gmail.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Rik van Riel <riel@redhat.com>, Casey Schaufler <casey@schaufler-ca.com>, PaX Team <pageexec@freemail.hu>, Brad Spengler <spender@grsecurity.net>, Russell King <linux@armlinux.org.uk>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Michael Ellerman <mpe@ellerman.id.au>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, "David S. Miller" <davem@davemloft.net>, x86@kernel.org, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, Borislav Petkov <bp@suse.de>, Mathias Krause <minipli@googlemail.com>, Jan Kara <jack@suse.cz>, Vitaly Wool <vitalywool@gmail.com>, Andrea Arcangeli <aarcange@redhat.com>, Dmitry Vyukov <dvyukov@google.com>, Laura Abbott <labbott@fedoraproject.org>, linux-arm-kernel@lists.infradead.org, linux-ia64@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, sparclinux@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, kernel-hardening@lists.openwall.com

Enables CONFIG_HARDENED_USERCOPY checks on x86. This is done both in
copy_*_user() and __copy_*_user() because copy_*_user() actually calls
down to _copy_*_user() and not __copy_*_user().

Based on code from PaX and grsecurity.

Signed-off-by: Kees Cook <keescook@chromium.org>
Tested-By: Valdis Kletnieks <valdis.kletnieks@vt.edu>
---
 arch/x86/Kconfig                  |  2 ++
 arch/x86/include/asm/uaccess.h    | 10 ++++++----
 arch/x86/include/asm/uaccess_32.h |  2 ++
 arch/x86/include/asm/uaccess_64.h |  2 ++
 4 files changed, 12 insertions(+), 4 deletions(-)

diff --git a/arch/x86/Kconfig b/arch/x86/Kconfig
index 4407f596b72c..39d89e058249 100644
--- a/arch/x86/Kconfig
+++ b/arch/x86/Kconfig
@@ -80,11 +80,13 @@ config X86
 	select HAVE_ALIGNED_STRUCT_PAGE		if SLUB
 	select HAVE_AOUT			if X86_32
 	select HAVE_ARCH_AUDITSYSCALL
+	select HAVE_ARCH_HARDENED_USERCOPY
 	select HAVE_ARCH_HUGE_VMAP		if X86_64 || X86_PAE
 	select HAVE_ARCH_JUMP_LABEL
 	select HAVE_ARCH_KASAN			if X86_64 && SPARSEMEM_VMEMMAP
 	select HAVE_ARCH_KGDB
 	select HAVE_ARCH_KMEMCHECK
+	select HAVE_ARCH_LINEAR_KERNEL_MAPPING	if X86_64
 	select HAVE_ARCH_MMAP_RND_BITS		if MMU
 	select HAVE_ARCH_MMAP_RND_COMPAT_BITS	if MMU && COMPAT
 	select HAVE_ARCH_SECCOMP_FILTER
diff --git a/arch/x86/include/asm/uaccess.h b/arch/x86/include/asm/uaccess.h
index 2982387ba817..d3312f0fcdfc 100644
--- a/arch/x86/include/asm/uaccess.h
+++ b/arch/x86/include/asm/uaccess.h
@@ -742,9 +742,10 @@ copy_from_user(void *to, const void __user *from, unsigned long n)
 	 * case, and do only runtime checking for non-constant sizes.
 	 */
 
-	if (likely(sz < 0 || sz >= n))
+	if (likely(sz < 0 || sz >= n)) {
+		check_object_size(to, n, false);
 		n = _copy_from_user(to, from, n);
-	else if(__builtin_constant_p(n))
+	} else if (__builtin_constant_p(n))
 		copy_from_user_overflow();
 	else
 		__copy_from_user_overflow(sz, n);
@@ -762,9 +763,10 @@ copy_to_user(void __user *to, const void *from, unsigned long n)
 	might_fault();
 
 	/* See the comment in copy_from_user() above. */
-	if (likely(sz < 0 || sz >= n))
+	if (likely(sz < 0 || sz >= n)) {
+		check_object_size(from, n, true);
 		n = _copy_to_user(to, from, n);
-	else if(__builtin_constant_p(n))
+	} else if (__builtin_constant_p(n))
 		copy_to_user_overflow();
 	else
 		__copy_to_user_overflow(sz, n);
diff --git a/arch/x86/include/asm/uaccess_32.h b/arch/x86/include/asm/uaccess_32.h
index 4b32da24faaf..7d3bdd1ed697 100644
--- a/arch/x86/include/asm/uaccess_32.h
+++ b/arch/x86/include/asm/uaccess_32.h
@@ -37,6 +37,7 @@ unsigned long __must_check __copy_from_user_ll_nocache_nozero
 static __always_inline unsigned long __must_check
 __copy_to_user_inatomic(void __user *to, const void *from, unsigned long n)
 {
+	check_object_size(from, n, true);
 	return __copy_to_user_ll(to, from, n);
 }
 
@@ -95,6 +96,7 @@ static __always_inline unsigned long
 __copy_from_user(void *to, const void __user *from, unsigned long n)
 {
 	might_fault();
+	check_object_size(to, n, false);
 	if (__builtin_constant_p(n)) {
 		unsigned long ret;
 
diff --git a/arch/x86/include/asm/uaccess_64.h b/arch/x86/include/asm/uaccess_64.h
index 2eac2aa3e37f..673059a109fe 100644
--- a/arch/x86/include/asm/uaccess_64.h
+++ b/arch/x86/include/asm/uaccess_64.h
@@ -54,6 +54,7 @@ int __copy_from_user_nocheck(void *dst, const void __user *src, unsigned size)
 {
 	int ret = 0;
 
+	check_object_size(dst, size, false);
 	if (!__builtin_constant_p(size))
 		return copy_user_generic(dst, (__force void *)src, size);
 	switch (size) {
@@ -119,6 +120,7 @@ int __copy_to_user_nocheck(void __user *dst, const void *src, unsigned size)
 {
 	int ret = 0;
 
+	check_object_size(src, size, true);
 	if (!__builtin_constant_p(size))
 		return copy_user_generic((__force void *)dst, src, size);
 	switch (size) {
-- 
2.7.4

