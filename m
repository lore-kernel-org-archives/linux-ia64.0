From: mita@miraclelinux.com (Akinobu Mita)
Date: Wed, 25 Jan 2006 11:34:46 +0000
Subject: [PATCH 5/6] fix warning on test_ti_thread_flag()
Message-Id: <20060125113446.GF18584@miraclelinux.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060125112625.GA18584@miraclelinux.com>
In-Reply-To: <20060125112625.GA18584@miraclelinux.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org
Cc: Richard Henderson <rth@twiddle.net>, Ivan Kokshaysky <ink@jurassic.park.msu.ru>, Russell King <rmk@arm.linux.org.uk>, Ian Molton <spyro@f2s.com>, dev-etrax@axis.com, David Howells <dhowells@redhat.com>, Yoshinori Sato <ysato@users.sourceforge.jp>, Linus Torvalds <torvalds@osdl.org>, linux-ia64@vger.kernel.org, Hirokazu Takata <takata@linux-m32r.org>, linux-m68k@vger.kernel.org, Greg Ungerer <gerg@uclinux.org>, linux-mips@linux-mips.org, parisc-linux@parisc-linux.org, linuxppc-dev@ozlabs.org, linux390@de.ibm.com, linuxsh-dev@lists.sourceforge.net, linuxsh-shmedia-dev@lists.sourceforge.net, sparclinux@vger.kernel.org, ultralinux@vger.kernel.org, Miles Bader <uclinux-v850@lsi.nec.co.jp>, Andi Kleen <ak@suse.de>, Chris Zankel <chris@zankel.net>

If the arechitecture is
- BITS_PER_LONG = 64
- struct thread_info.flag 32 is bits
- second argument of test_bit() was void *

Then compiler print error message on test_ti_thread_flags()
in include/linux/thread_info.h

Signed-off-by: Akinobu Mita <mita@miraclelinux.com>
---
 thread_info.h |    2 +-
 1 files changed, 1 insertion(+), 1 deletion(-)

Index: 2.6-git/include/linux/thread_info.h
=================================--- 2.6-git.orig/include/linux/thread_info.h	2006-01-25 19:07:12.000000000 +0900
+++ 2.6-git/include/linux/thread_info.h	2006-01-25 19:14:26.000000000 +0900
@@ -49,7 +49,7 @@
 
 static inline int test_ti_thread_flag(struct thread_info *ti, int flag)
 {
-	return test_bit(flag,&ti->flags);
+	return test_bit(flag, (void *)&ti->flags);
 }
 
 #define set_thread_flag(flag) \
