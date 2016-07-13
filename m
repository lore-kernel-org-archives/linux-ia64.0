From: Kees Cook <keescook@chromium.org>
Date: Wed, 13 Jul 2016 21:56:04 +0000
Subject: [PATCH v2 11/11] mm: SLUB hardened usercopy support
Message-Id: <1468446964-22213-12-git-send-email-keescook@chromium.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <1468446964-22213-1-git-send-email-keescook@chromium.org>
In-Reply-To: <1468446964-22213-1-git-send-email-keescook@chromium.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org
Cc: Kees Cook <keescook@chromium.org>, Rik van Riel <riel@redhat.com>, Casey Schaufler <casey@schaufler-ca.com>, PaX Team <pageexec@freemail.hu>, Brad Spengler <spender@grsecurity.net>, Russell King <linux@armlinux.org.uk>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Michael Ellerman <mpe@ellerman.id.au>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, "David S. Miller" <davem@davemloft.net>, x86@kernel.org, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, Borislav Petkov <bp@suse.de>, Mathias Krause <minipli@googlemail.com>, Jan Kara <jack@suse.cz>, Vitaly Wool <vitalywool@gmail.com>, Andrea Arcangeli <aarcange@redhat.com>, Dmitry Vyukov <dvyukov@google.com>, Laura Abbott <labbott@fedoraproject.org>, linux-arm-kernel@lists.infradead.org, linux-ia64@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, sparclinux@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, kernel-hardening@lists.openwall.com

Under CONFIG_HARDENED_USERCOPY, this adds object size checking to the
SLUB allocator to catch any copies that may span objects. Includes a
redzone handling fix from Michael Ellerman.

Based on code from PaX and grsecurity.

Signed-off-by: Kees Cook <keescook@chromium.org>
---
 init/Kconfig |  1 +
 mm/slub.c    | 36 ++++++++++++++++++++++++++++++++++++
 2 files changed, 37 insertions(+)

diff --git a/init/Kconfig b/init/Kconfig
index 798c2020ee7c..1c4711819dfd 100644
--- a/init/Kconfig
+++ b/init/Kconfig
@@ -1765,6 +1765,7 @@ config SLAB
 
 config SLUB
 	bool "SLUB (Unqueued Allocator)"
+	select HAVE_HARDENED_USERCOPY_ALLOCATOR
 	help
 	   SLUB is a slab allocator that minimizes cache line usage
 	   instead of managing queues of cached objects (SLAB approach).
diff --git a/mm/slub.c b/mm/slub.c
index 825ff4505336..7dee3d9a5843 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -3614,6 +3614,42 @@ void *__kmalloc_node(size_t size, gfp_t flags, int node)
 EXPORT_SYMBOL(__kmalloc_node);
 #endif
 
+#ifdef CONFIG_HARDENED_USERCOPY
+/*
+ * Rejects objects that are incorrectly sized.
+ *
+ * Returns NULL if check passes, otherwise const char * to name of cache
+ * to indicate an error.
+ */
+const char *__check_heap_object(const void *ptr, unsigned long n,
+				struct page *page)
+{
+	struct kmem_cache *s;
+	unsigned long offset;
+	size_t object_size;
+
+	/* Find object and usable object size. */
+	s = page->slab_cache;
+	object_size = slab_ksize(s);
+
+	/* Find offset within object. */
+	offset = (ptr - page_address(page)) % s->size;
+
+	/* Adjust for redzone and reject if within the redzone. */
+	if (kmem_cache_debug(s) && s->flags & SLAB_RED_ZONE) {
+		if (offset < s->red_left_pad)
+			return s->name;
+		offset -= s->red_left_pad;
+	}
+
+	/* Allow address range falling entirely within object size. */
+	if (offset <= object_size && n <= object_size - offset)
+		return NULL;
+
+	return s->name;
+}
+#endif /* CONFIG_HARDENED_USERCOPY */
+
 static size_t __ksize(const void *object)
 {
 	struct page *page;
-- 
2.7.4

