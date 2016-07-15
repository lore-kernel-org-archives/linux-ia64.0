From: Kees Cook <keescook@chromium.org>
Date: Fri, 15 Jul 2016 21:44:23 +0000
Subject: [PATCH v3 09/11] s390/uaccess: Enable hardened usercopy
Message-Id: <1468619065-3222-10-git-send-email-keescook@chromium.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <1468619065-3222-1-git-send-email-keescook@chromium.org>
In-Reply-To: <1468619065-3222-1-git-send-email-keescook@chromium.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org
Cc: Kees Cook <keescook@chromium.org>, Balbir Singh <bsingharora@gmail.com>, Daniel Micay <danielmicay@gmail.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Rik van Riel <riel@redhat.com>, Casey Schaufler <casey@schaufler-ca.com>, PaX Team <pageexec@freemail.hu>, Brad Spengler <spender@grsecurity.net>, Russell King <linux@armlinux.org.uk>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Michael Ellerman <mpe@ellerman.id.au>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, "David S. Miller" <davem@davemloft.net>, x86@kernel.org, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, Borislav Petkov <bp@suse.de>, Mathias Krause <minipli@googlemail.com>, Jan Kara <jack@suse.cz>, Vitaly Wool <vitalywool@gmail.com>, Andrea Arcangeli <aarcange@redhat.com>, Dmitry Vyukov <dvyukov@google.com>, Laura Abbott <labbott@fedoraproject.org>, linux-arm-kernel@lists.infradead.org, linux-ia64@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, sparclinux@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, kernel-hardening@lists.openwall.com

Enables CONFIG_HARDENED_USERCOPY checks on s390.

Signed-off-by: Kees Cook <keescook@chromium.org>
---
 arch/s390/Kconfig       | 1 +
 arch/s390/lib/uaccess.c | 2 ++
 2 files changed, 3 insertions(+)

diff --git a/arch/s390/Kconfig b/arch/s390/Kconfig
index a8c259059adf..9f694311c9ed 100644
--- a/arch/s390/Kconfig
+++ b/arch/s390/Kconfig
@@ -122,6 +122,7 @@ config S390
 	select HAVE_ALIGNED_STRUCT_PAGE if SLUB
 	select HAVE_ARCH_AUDITSYSCALL
 	select HAVE_ARCH_EARLY_PFN_TO_NID
+	select HAVE_ARCH_HARDENED_USERCOPY
 	select HAVE_ARCH_JUMP_LABEL
 	select CPU_NO_EFFICIENT_FFS if !HAVE_MARCH_Z9_109_FEATURES
 	select HAVE_ARCH_SECCOMP_FILTER
diff --git a/arch/s390/lib/uaccess.c b/arch/s390/lib/uaccess.c
index ae4de559e3a0..6986c20166f0 100644
--- a/arch/s390/lib/uaccess.c
+++ b/arch/s390/lib/uaccess.c
@@ -104,6 +104,7 @@ static inline unsigned long copy_from_user_mvcp(void *x, const void __user *ptr,
 
 unsigned long __copy_from_user(void *to, const void __user *from, unsigned long n)
 {
+	check_object_size(to, n, false);
 	if (static_branch_likely(&have_mvcos))
 		return copy_from_user_mvcos(to, from, n);
 	return copy_from_user_mvcp(to, from, n);
@@ -177,6 +178,7 @@ static inline unsigned long copy_to_user_mvcs(void __user *ptr, const void *x,
 
 unsigned long __copy_to_user(void __user *to, const void *from, unsigned long n)
 {
+	check_object_size(from, n, true);
 	if (static_branch_likely(&have_mvcos))
 		return copy_to_user_mvcos(to, from, n);
 	return copy_to_user_mvcs(to, from, n);
-- 
2.7.4

