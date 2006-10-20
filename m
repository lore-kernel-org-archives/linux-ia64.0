From: Horms <horms@verge.net.au>
Date: Fri, 20 Oct 2006 05:52:01 +0000
Subject: Re: Kexec/Kdump: honour non-zero crashkernel offset.
Message-Id: <20061020055200.GA11527@verge.net.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060920024544.733881000@tabatha.lab.ultramonkey.org>
In-Reply-To: <20060920024544.733881000@tabatha.lab.ultramonkey.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, Sep 21, 2006 at 06:45:48PM +0900, Horms wrote:
> On Thu, Sep 21, 2006 at 01:49:09PM +0800, Zou, Nanhai wrote:
> > 	This patch is still incorrect. You will miss the rsvd_region code if base not equals 0. 
> 
> Thanks, I guess this is closer, though I'm assuming that calling
> sort_regions() isn't needed unless kdump_find_rsvd_region() is going
> to be called.

Hi,

here is yet another version of this patch. This time I tested it
and it actually seems to work (unlike previous itterations I sent).

-- 
Horms
  H: http://www.vergenet.net/~horms/
  W: http://www.valinux.co.jp/en/

[IA64] Kexec/Kdump: honour non-zero crashkernel offset.

There seems to be a value in both allowing the kernel to determine
the base offset of the crashkernel automatically and allowing
users's to sepcify it.

The old behaviour on ia64, which is still the current behaviour on
most architectures is for the user to always specify the address.
Recently ia64 was changed so that it is always automatically determined.

With this patch the kernel automatically determines the offset if
the supplied value is 0, otherwise it uses the value provided.

This should probably be backed by a documentation change.

Signed-Off-By: Simon Horman <horms@verge.net.au>

Index: kexec-ia64-2.6/arch/ia64/kernel/setup.c
=================================--- kexec-ia64-2.6.orig/arch/ia64/kernel/setup.c	2006-10-20 13:13:38.000000000 +0900
+++ kexec-ia64-2.6/arch/ia64/kernel/setup.c	2006-10-20 14:49:05.000000000 +0900
@@ -257,7 +257,7 @@
 
 #ifdef CONFIG_KEXEC
 	/* crashkernel=size@offset specifies the size to reserve for a crash
-	 * kernel.(offset is ingored for keep compatibility with other archs)
+	 * kernel. If offset is 0, then it is determined automatically.
 	 * By reserving this memory we guarantee that linux never set's it
 	 * up as a DMA target.Useful for holding code to do something
 	 * appropriate after a kernel panic.
@@ -267,10 +267,16 @@
 		unsigned long base, size;
 		if (from) {
 			size = memparse(from + 12, &from);
+			if (*from = '@')
+				base = memparse(from+1, &from);
+			else
+				base = 0;
 			if (size) {
-				sort_regions(rsvd_region, n);
-				base = kdump_find_rsvd_region(size,
-				rsvd_region, n);
+				if (!base) {
+					sort_regions(rsvd_region, n);
+					base = kdump_find_rsvd_region(size,
+							      	rsvd_region, n);
+					}
 				if (base != ~0UL) {
 					rsvd_region[n].start  						(unsigned long)__va(base);
