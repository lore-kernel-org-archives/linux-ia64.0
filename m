From: Ard Biesheuvel <ardb@kernel.org>
Date: Wed, 15 Feb 2023 10:00:07 +0000
Subject: [RFC PATCH 4/5] lib/raid6: Drop IA64 support
Message-Id: <20230215100008.2565237-5-ardb@kernel.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20230215100008.2565237-1-ardb@kernel.org>
In-Reply-To: <20230215100008.2565237-1-ardb@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org
Cc: Ard Biesheuvel <ardb@kernel.org>, Jonathan Corbet <corbet@lwn.net>, Arnd Bergmann <arnd@arndb.de>, Tony Luck <tony.luck@intel.com>, Jessica Clarke <jrtc27@jrtc27.com>, John Paul Adrian Glaubitz <glaubitz@physik.fu-berlin.de>, Matthew Wilcox <willy@infradead.org>, Marc Zyngier <maz@kernel.org>, Guenter Roeck <linux@roeck-us.net>, Linus Torvalds <torvalds@linux-foundation.org>, linux-ia64@vger.kernel.org

Drop Itanium support from the RAID6 code, and along with it, the 16x and
32x unrolled versions, which were only used by IA64.

Signed-off-by: Ard Biesheuvel <ardb@kernel.org>
---
 include/linux/raid/pq.h | 2 --
 lib/raid6/Makefile      | 4 ++--
 lib/raid6/algos.c       | 4 ----
 3 files changed, 2 insertions(+), 8 deletions(-)

diff --git a/include/linux/raid/pq.h b/include/linux/raid/pq.h
index f29aaaf2eb21e9bd..f2536c99141aad77 100644
--- a/include/linux/raid/pq.h
+++ b/include/linux/raid/pq.h
@@ -84,8 +84,6 @@ extern const struct raid6_calls raid6_intx1;
 extern const struct raid6_calls raid6_intx2;
 extern const struct raid6_calls raid6_intx4;
 extern const struct raid6_calls raid6_intx8;
-extern const struct raid6_calls raid6_intx16;
-extern const struct raid6_calls raid6_intx32;
 extern const struct raid6_calls raid6_mmxx1;
 extern const struct raid6_calls raid6_mmxx2;
 extern const struct raid6_calls raid6_sse1x1;
diff --git a/lib/raid6/Makefile b/lib/raid6/Makefile
index 45e17619422b4ef4..065a31e8f71df898 100644
--- a/lib/raid6/Makefile
+++ b/lib/raid6/Makefile
@@ -2,7 +2,7 @@
 obj-$(CONFIG_RAID6_PQ)	+= raid6_pq.o
 
 raid6_pq-y	+= algos.o recov.o tables.o int1.o int2.o int4.o \
-		   int8.o int16.o int32.o
+		   int8.o
 
 raid6_pq-$(CONFIG_X86) += recov_ssse3.o recov_avx2.o mmx.o sse1.o sse2.o avx2.o avx512.o recov_avx512.o
 raid6_pq-$(CONFIG_ALTIVEC) += altivec1.o altivec2.o altivec4.o altivec8.o \
@@ -54,7 +54,7 @@ endif
 quiet_cmd_unroll = UNROLL  $@
       cmd_unroll = $(AWK) -v N=$* -f $(srctree)/$(src)/unroll.awk < $< > $@
 
-targets += int1.c int2.c int4.c int8.c int16.c int32.c
+targets += int1.c int2.c int4.c int8.c
 $(obj)/int%.c: $(src)/int.uc $(src)/unroll.awk FORCE
 	$(call if_changed,unroll)
 
diff --git a/lib/raid6/algos.c b/lib/raid6/algos.c
index a22a05c9af8a3a75..fd1e699fa5fc19ae 100644
--- a/lib/raid6/algos.c
+++ b/lib/raid6/algos.c
@@ -72,10 +72,6 @@ const struct raid6_calls * const raid6_algos[] = {
 	&raid6_neonx4,
 	&raid6_neonx2,
 	&raid6_neonx1,
-#endif
-#if defined(__ia64__)
-	&raid6_intx32,
-	&raid6_intx16,
 #endif
 	&raid6_intx8,
 	&raid6_intx4,
-- 
2.39.1
