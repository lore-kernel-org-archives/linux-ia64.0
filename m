From: Laura Abbott <labbott@redhat.com>
Date: Tue, 19 Jul 2016 22:00:04 +0000
Subject: [PATCH] mm: Add is_migrate_cma_page
Message-Id: <1468965604-25023-1-git-send-email-labbott@redhat.com>
List-Id: <linux-ia64.vger.kernel.org>
In-Reply-To: <CAGXu5j+nHpHcYT8FyHNe6AFQCdakoSMW=UWDatyxhRK7CB7_=g@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org
Cc: Laura Abbott <labbott@redhat.com>, Kees Cook <keescook@chromium.org>, Rik van Riel <riel@redhat.com>, Casey Schaufler <casey@schaufler-ca.com>, PaX Team <pageexec@freemail.hu>, Brad Spengler <spender@grsecurity.net>, Russell King <linux@armlinux.org.uk>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Michael Ellerman <mpe@ellerman.id.au>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, "David S. Miller" <davem@davemloft.net>, x86@kernel.org, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, Borislav Petkov <bp@suse.de>, Mathias Krause <minipli@googlemail.com>, Jan Kara <jack@suse.cz>, Vitaly Wool <vitalywool@gmail.com>, Andrea Arcangeli <aarcange@redhat.com>, Dmitry Vyukov <dvyukov@google.com>, Laura Abbott <labbott@fedoraproject.org>, linux-arm-kernel@lists.infradead.org, linux-ia64@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, sparclinux@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, kernel-hardening@lists.openwall.com

Code such as hardened user copy[1] needs a way to tell if a
page is CMA or not. Add is_migrate_cma_page in a similar way
to is_migrate_isolate_page.

[1]http://article.gmane.org/gmane.linux.kernel.mm/155238

Signed-off-by: Laura Abbott <labbott@redhat.com>
---
Here's an explicit patch, slightly different than what I posted before. It can
be kept separate or folded in as needed.
---
 include/linux/mmzone.h | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index 02069c2..c8478b2 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -68,8 +68,10 @@ extern char * const migratetype_names[MIGRATE_TYPES];
 
 #ifdef CONFIG_CMA
 #  define is_migrate_cma(migratetype) unlikely((migratetype) = MIGRATE_CMA)
+#  define is_migrate_cma_page(_page) (get_pageblock_migratetype(_page) = MIGRATE_CMA)
 #else
 #  define is_migrate_cma(migratetype) false
+#  define is_migrate_cma_page(_page) false
 #endif
 
 #define for_each_migratetype_order(order, type) \
-- 
2.7.4

