From: Keith Owens <kaos@ocs.com.au>
Date: Thu, 23 Oct 2003 21:04:21 +0000
Subject: Re: PATCH 2.4.23-pre6 add kmap_types.h for CONFIG_CRYPTO
Message-Id: <marc-linux-ia64-106694325730190@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106633278923482@msgid-missing>
In-Reply-To: <marc-linux-ia64-106633278923482@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, 23 Oct 2003 11:01:40 -0600, 
Bjorn Helgaas <bjorn.helgaas@hp.com> wrote:
>Here's my proposal for a fix.  I don't think I'll send it to Linus/Andrew
>yet, because it's really a cleanup, not an actual bug fix, but here it
>is for any comments.
>
>Currently every architecture must supply kmap_types.h, even though
>it only makes sense for architectures that use highmem.
>
>This patch removes the need for generic code to know about kmap_types.h
>by adding the appropriate #include to include/linux/highmem.h and
>defining a minimal set of KM_ enums that are used by generic code.
>
>One might argue that we shouldn't need to define even the minimal
>set of KM_ enums, but generic code needs to be able to do, for
>example:
>
>	kmap_atomic(page, KM_USER);
>
>In many cases the KM_USER needn't be defined at all because the
>non-highmem kmap_atomic() never evaluates it, but leaving it
>undefined also restricts generic code from doing other things
>like defining an array of KM_ types.  crypto/cipher.c defines
>such an array, and it seems non-intuitive to prevent that usage.

I disagree with this fix.  All uses of KM_ variables are restricted to
headers that make their use conditional on CONFIG_HIGHMEM.  crypto is
the only expection and the correct fix is to change crypto to test
CONFIG_HIGHMEM, not to change every architecture.  Untested.


Index: 23-pre7.1/crypto/internal.h
--- 23-pre7.1/crypto/internal.h Sun, 06 Jul 2003 14:16:24 +1000 kaos (linux-2.4/Y/g/31_internal.h 1.1 644)
+++ 23-pre7.1(w)/crypto/internal.h Fri, 24 Oct 2003 07:00:24 +1000 kaos (linux-2.4/Y/g/31_internal.h 1.1 644)
@@ -16,14 +16,17 @@
 #include <linux/init.h>
 #include <asm/hardirq.h>
 #include <asm/softirq.h>
-#include <asm/kmap_types.h>
 
+#ifdef CONFIG_HIGHMEM
 extern enum km_type crypto_km_types[];
 
 static inline enum km_type crypto_kmap_type(int out)
 {
 	return crypto_km_types[(in_softirq() ? 2 : 0) + out];
 }
+#else
+#define crypto_kmap_type(out) crypto_kmap_type_not_used_on_this_arch
+#endif
 
 static inline void *crypto_kmap(struct page *page, int out)
 {
Index: 23-pre7.1/crypto/cipher.c
--- 23-pre7.1/crypto/cipher.c Sun, 06 Jul 2003 14:16:24 +1000 kaos (linux-2.4/Y/g/38_cipher.c 1.1 644)
+++ 23-pre7.1(w)/crypto/cipher.c Fri, 24 Oct 2003 06:58:11 +1000 kaos (linux-2.4/Y/g/38_cipher.c 1.1 644)
@@ -35,12 +35,14 @@ struct scatter_walk {
 	unsigned int		offset;
 };
 
+#ifdef CONFIG_HIGHMEM
 enum km_type crypto_km_types[] = {
 	KM_USER0,
 	KM_USER1,
 	KM_SOFTIRQ0,
 	KM_SOFTIRQ1,
 };
+#endif
 
 static inline void xor_64(u8 *a, const u8 *b)
 {

