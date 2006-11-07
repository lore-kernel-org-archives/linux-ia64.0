From: Jes Sorensen <jes@sgi.com>
Date: Tue, 07 Nov 2006 10:31:54 +0000
Subject: Re: [PATCH 0/1] mspec driver: compile error
Message-Id: <4550609A.7010908@sgi.com>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="------------080705060107010202010701"
List-Id: <linux-ia64.vger.kernel.org>
References: <1162881017.13700.105.camel@sebastian.intellilink.co.jp>
In-Reply-To: <1162881017.13700.105.camel@sebastian.intellilink.co.jp>
To: =?ISO-8859-1?Q?Fernando_Luis_V=E1zquez_Cao?= <fernando@oss.ntt.co.jp>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, bjorn_helgaas@hp.com, Nick Piggin <nickpiggin@yahoo.com.au>, Andrew Morton <akpm@osdl.org>, Robin Holt <holt@sgi.com>, Dean Nelson <dcn@sgi.com>, Hugh Dickins <hugh@veritas.com>, Linus Torvalds <torvalds@osdl.org>, linux-ia64 <linux-ia64@vger.kernel.org>, Tony Luck <tony.luck@gmail.com>

This is a multi-part message in MIME format.
--------------080705060107010202010701
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable

Fernando Luis V=E1zquez Cao wrote:
> Hi Jes,
>=20
> After selecting CONFIG_MSPEC as a module I stumbled onto the compile
> error below.
[snip]
> I'll be replying to this message with a patch that implements this. I
> would appreciate your review and comments.

Hi Fernando,

As I also mentioned in my reply to Peter Chubb, this is the wrong fix
for this problem as the driver should operate in cached and uncached
mode on non SN2 systems.

Here is the correct fix. I have test it on SN2 and made sure it builds
for DIG, but I can't easily test it. However I see no reason why it
should cause problems.

This is ending up as an attachment since it ended up in the IMAP only
mailbox. Somehow I am willing to bet Thunderbug will do something stupid
to it, like base64 encode it.

Cheers,
Jes

PS: When you post fixes for an IA64 specific driver like this, please
    always remember to CC the ia64 list and the ia64 maintainer on it!

--------------080705060107010202010701
Content-Type: text/plain;
 name="mspec-dig-build.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="mspec-dig-build.diff"

Fix MSPEC driver to build for non SN2 enabled configs as the driver
should work in cached and uncached modes (no fetchop) on these systems.
In addition make MSPEC select IA64_UNCACHED_ALLOCATOR, which is required
for it.

Signed-off-by: Jes Sorensen <jes@sgi.com>

---
 drivers/char/Kconfig        |    1 +
 drivers/char/mspec.c        |    8 +++++++-
 include/asm-ia64/sn/addrs.h |    6 +++++-
 3 files changed, 13 insertions(+), 2 deletions(-)

Index: linux-2.6/drivers/char/Kconfig
===================================================================
--- linux-2.6.orig/drivers/char/Kconfig
+++ linux-2.6/drivers/char/Kconfig
@@ -412,6 +412,7 @@ config SGI_MBCS
 config MSPEC
 	tristate "Memory special operations driver"
 	depends on IA64
+	select IA64_UNCACHED_ALLOCATOR
 	help
 	  If you have an ia64 and you want to enable memory special
 	  operations support (formerly known as fetchop), say Y here,
Index: linux-2.6/drivers/char/mspec.c
===================================================================
--- linux-2.6.orig/drivers/char/mspec.c
+++ linux-2.6/drivers/char/mspec.c
@@ -72,7 +72,11 @@ enum {
 	MSPEC_UNCACHED
 };
 
+#ifdef CONFIG_SGI_SN
 static int is_sn2;
+#else
+#define is_sn2		0
+#endif
 
 /*
  * One of these structures is allocated when an mspec region is mmaped. The
@@ -211,7 +215,7 @@ mspec_nopfn(struct vm_area_struct *vma, 
 	if (vdata->type == MSPEC_FETCHOP)
 		paddr = TO_AMO(maddr);
 	else
-		paddr = __pa(TO_CAC(maddr));
+		paddr = maddr & ~__IA64_UNCACHED_OFFSET;
 
 	pfn = paddr >> PAGE_SHIFT;
 
@@ -335,6 +339,7 @@ mspec_init(void)
 	 * The fetchop device only works on SN2 hardware, uncached and cached
 	 * memory drivers should both be valid on all ia64 hardware
 	 */
+#ifdef CONFIG_SGI_SN
 	if (ia64_platform_is("sn2")) {
 		is_sn2 = 1;
 		if (is_shub2()) {
@@ -363,6 +368,7 @@ mspec_init(void)
 			goto free_scratch_pages;
 		}
 	}
+#endif
 	ret = misc_register(&cached_miscdev);
 	if (ret) {
 		printk(KERN_ERR "%s: failed to register device %i\n",
Index: linux-2.6/include/asm-ia64/sn/addrs.h
===================================================================
--- linux-2.6.orig/include/asm-ia64/sn/addrs.h
+++ linux-2.6/include/asm-ia64/sn/addrs.h
@@ -136,9 +136,13 @@
  */
 #define TO_PHYS(x)		(TO_PHYS_MASK & (x))
 #define TO_CAC(x)		(CAC_BASE     | TO_PHYS(x))
+#ifdef CONFIG_SGI_SN
 #define TO_AMO(x)		(AMO_BASE     | TO_PHYS(x))
 #define TO_GET(x)		(GET_BASE     | TO_PHYS(x))
-
+#else
+#define TO_AMO(x)		({ BUG(); x; })
+#define TO_GET(x)		({ BUG(); x; })
+#endif
 
 /*
  * Covert from processor physical address to II/TIO physical address:

--------------080705060107010202010701--
