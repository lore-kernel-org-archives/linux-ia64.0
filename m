From: jbarnes@sgi.com (Jesse Barnes)
Date: Tue, 23 Sep 2003 17:25:09 +0000
Subject: Re: [PATCH] split contig and discontig functions
Message-Id: <marc-linux-ia64-106433859802253@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106428053212055@msgid-missing>
In-Reply-To: <marc-linux-ia64-106428053212055@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, Sep 23, 2003 at 10:17:11AM -0700, David Mosberger wrote:
> 
>   Jesse> Oops, I forgot to make meminit.h protect against multiple
>   Jesse> inclusion and there are some other minor formatting stuff
>   Jesse> that I missed.  I'll post another patch shortly.
> 
> Don't worry about it.  I already checked in a variant of your patch that
> fixes those things.  Should be in the bk repo shortly (sometime today).

Wow, that was fast :).  Here's what I was gonna put in, just a comment
fix and the include file thing.

Jesse

diff -Nru a/arch/ia64/kernel/setup.c b/arch/ia64/kernel/setup.c
--- a/arch/ia64/kernel/setup.c	Tue Sep 23 10:23:37 2003
+++ b/arch/ia64/kernel/setup.c	Tue Sep 23 10:23:37 2003
@@ -159,9 +159,10 @@
  * reserve_memory - setup reserved memory areas
  *
  * Setup the reserved memory areas set aside for the boot parameters, initrd,
- * etc.
+ * etc.  There are currently %IA64_MAX_RSVD_REGIONS defined, see
+ * include/asm-ia64/meminit.h if you need to define more.
  */
-void reserve_memory (void)
+void reserve_memory(void)
 {
 	int n = 0;
 
diff -Nru a/include/asm-ia64/meminit.h b/include/asm-ia64/meminit.h
--- a/include/asm-ia64/meminit.h	Tue Sep 23 10:23:37 2003
+++ b/include/asm-ia64/meminit.h	Tue Sep 23 10:23:37 2003
@@ -3,6 +3,8 @@
  * License.  See the file "COPYING" in the main directory of this archive
  * for more details.
  */
+#ifndef _MEMINIT_H_
+#define _MEMINIT_H_
 
 /*
  * Entries defined so far:
@@ -36,3 +38,4 @@
 
 #define IGNORE_PFN0	1	/* XXX fix me: ignore pfn 0 until TLB miss
 				   handler is updated... */
+#endif /* _MEMINIT_H_ */
