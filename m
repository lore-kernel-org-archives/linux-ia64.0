From: Fenghua Yu <fenghua.yu@intel.com>
Date: Mon, 31 Aug 2009 19:28:35 +0000
Subject: [PATCH] linux-next drm_cache.c: fix compilation error
Message-Id: <20090831192834.GA10462@linux-os.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <bug-504363-150293@bugzilla.redhat.com> <200908042017.n74KHsNw018095@bz-web1.app.phx.redhat.com> <20090804221119.GA21544@linux-os.sc.intel.com>
In-Reply-To: <20090804221119.GA21544@linux-os.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Stephen Rothwell <sfr@canb.auug.org.au>, Dave Airlie <airlied@redhat.com>
Cc: Tony luck <tony.luck@intel.com>, linux-ia64 <linux-ia64@vger.kernel.org>, lkml <linux-kernel@vger.kernel.org>, linux-next <linux-next@vger.kernel.org>

When compiling drm_cache.c on ia64, gcc reports undefined
drm_clflush_ipi_handler() error. The problem is because drm_cache_ipi_handler is
a typo.

One straightforward fix is changing drm_cache_ipi_handler to
drm_clflush_ipi_handler.

But since drm_clflush_ipi_handler() does nothing on non-x86 platforms and ipi
handling is costly, it would be better to just do nothing on non-x86 platforms
and remove drm_clflush_ipi_handler() for those platforms.

Signed-off-by: Fenghua Yu <fenghua.yu@intel.com>

---
The issue was introduced by commit c9c97b8c75019814d8c007059bc827bb475be917
in linux-next.

 drm_cache.c |    7 -------
 1 files changed, 7 deletions(-)

diff --git a/drivers/gpu/drm/drm_cache.c b/drivers/gpu/drm/drm_cache.c
index 3a5575e..8054a5c 100644
--- a/drivers/gpu/drm/drm_cache.c
+++ b/drivers/gpu/drm/drm_cache.c
@@ -62,10 +62,6 @@ drm_clflush_ipi_handler(void *null)
 {
 	wbinvd();
 }
-#elif !defined(__powerpc__)
-static void drm_cache_ipi_handler(void *dummy)
-{
-}
 #endif
 void
 drm_clflush_pages(struct page *pages[], unsigned long num_pages)
@@ -94,9 +90,6 @@ drm_clflush_pages(struct page *pages[], unsigned long num_pages)
 				   (unsigned long)page_virtual + PAGE_SIZE);
 		kunmap_atomic(page_virtual, KM_USER0);
 	}
-#else
-	if (on_each_cpu(drm_clflush_ipi_handler, NULL, 1) != 0)
-		printk(KERN_ERR "Timed out waiting for drm cache flush\n");
 #endif
 }
 EXPORT_SYMBOL(drm_clflush_pages);
