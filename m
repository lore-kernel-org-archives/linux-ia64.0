From: Akinobu Mita <mita@miraclelinux.com>
Date: Wed, 01 Feb 2006 09:02:34 +0000
Subject: [patch 10/44] generic fls64()
Message-Id: <20060201090323.294297000@localhost.localdomain>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060201090224.536581000@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org
Cc: Richard Henderson <rth@twiddle.net>, Ivan Kokshaysky <ink@jurassic.park.msu.ru>, Russell King <rmk@arm.linux.org.uk>, Ian Molton <spyro@f2s.com>, dev-etrax@axis.com, David Howells <dhowells@redhat.com>, Yoshinori Sato <ysato@users.sourceforge.jp>, Linus Torvalds <torvalds@osdl.org>, linux-ia64@vger.kernel.org, Hirokazu Takata <takata@linux-m32r.org>, linux-m68k@vger.kernel.org, Greg Ungerer <gerg@uclinux.org>, linux-mips@linux-mips.org, parisc-linux@parisc-linux.org, linuxppc-dev@ozlabs.org, linux390@de.ibm.com, linuxsh-dev@lists.sourceforge.net, linuxsh-shmedia-dev@lists.sourceforge.net, sparclinux@vger.kernel.org, ultralinux@vger.kernel.org, Miles Bader <uclinux-v850@lsi.nec.co.jp>, Andi Kleen <ak@suse.de>, Chris Zankel <chris@zankel.net>, Akinobu Mita <mita@miraclelinux.com>

This patch introduces the C-language equivalent of the function:
int fls64(__u64 x);

In include/asm-generic/bitops/fls64.h

This code largely copied from:
include/linux/bitops.h

Signed-off-by: Akinobu Mita <mita@miraclelinux.com>
 include/asm-generic/bitops/fls64.h |   12 ++++++++++++
 1 files changed, 12 insertions(+)

Index: 2.6-git/include/asm-generic/bitops/fls64.h
=================================--- /dev/null
+++ 2.6-git/include/asm-generic/bitops/fls64.h
@@ -0,0 +1,12 @@
+#ifndef _ASM_GENERIC_BITOPS_FLS64_H_
+#define _ASM_GENERIC_BITOPS_FLS64_H_
+
+static inline int fls64(__u64 x)
+{
+	__u32 h = x >> 32;
+	if (h)
+		return fls(x) + 32;
+	return fls(x);
+}
+
+#endif /* _ASM_GENERIC_BITOPS_FLS64_H_ */

--
