From: Arnd Bergmann <arnd@kernel.org>
Date: Mon, 04 Jan 2021 08:58:02 +0000
Subject: [PATCH] ia64: fix xchg() warning
Message-Id: <20210104085806.4176886-1-arnd@kernel.org>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>
Cc: Arnd Bergmann <arnd@arndb.de>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

From: Arnd Bergmann <arnd@arndb.de>

The definition if xchg() causes a harmless warning in some files, like:

In file included from ../arch/ia64/include/uapi/asm/intrinsics.h:22,
                 from ../arch/ia64/include/asm/intrinsics.h:11,
                 from ../arch/ia64/include/asm/bitops.h:19,
                 from ../include/linux/bitops.h:32,
                 from ../include/linux/kernel.h:11,
                 from ../fs/nfs/read.c:12:
../fs/nfs/read.c: In function 'nfs_read_completion':
../arch/ia64/include/uapi/asm/cmpxchg.h:57:2: warning: value computed is not used [-Wunused-value]
   57 | ((__typeof__(*(ptr))) __xchg((unsigned long) (x), (ptr), sizeof(*(ptr))))
      | ~^~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
../fs/nfs/read.c:196:5: note: in expansion of macro 'xchg'
  196 |     xchg(&nfs_req_openctx(req)->error, error);
      |     ^~~~

Change it to a compound expression like the other architectures have
to get a clean defconfig build.

Signed-off-by: Arnd Bergmann <arnd@arndb.de>
---
 arch/ia64/include/uapi/asm/cmpxchg.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/arch/ia64/include/uapi/asm/cmpxchg.h b/arch/ia64/include/uapi/asm/cmpxchg.h
index d69c979936d4..5d90307fd6e0 100644
--- a/arch/ia64/include/uapi/asm/cmpxchg.h
+++ b/arch/ia64/include/uapi/asm/cmpxchg.h
@@ -54,7 +54,7 @@ extern void ia64_xchg_called_with_bad_pointer(void);
 })
 
 #define xchg(ptr, x)							\
-((__typeof__(*(ptr))) __xchg((unsigned long) (x), (ptr), sizeof(*(ptr))))
+({(__typeof__(*(ptr))) __xchg((unsigned long) (x), (ptr), sizeof(*(ptr)));})
 
 /*
  * Atomic compare and exchange.  Compare OLD with MEM, if identical,
-- 
2.29.2
