From: mita@miraclelinux.com (Akinobu Mita)
Date: Fri, 03 Feb 2006 01:27:35 +0000
Subject: [PATCH] fix generic_fls64()
Message-Id: <20060203012735.GA21567@miraclelinux.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <DCEAAC0833DD314AB0B58112AD99B93B859547@ismail.innsys.innovsys.com>
In-Reply-To: <DCEAAC0833DD314AB0B58112AD99B93B859547@ismail.innsys.innovsys.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Rune Torgersen <runet@innovsys.com>
Cc: linux-kernel@vger.kernel.org, linux-mips@linux-mips.org, linux-ia64@vger.kernel.org, Ian Molton <spyro@f2s.com>, David Howells <dhowells@redhat.com>, linuxppc-dev@ozlabs.org, Greg Ungerer <gerg@uclinux.org>, sparclinux@vger.kernel.org, Miles Bader <uclinux-v850@lsi.nec.co.jp>, Linus Torvalds <torvalds@osdl.org>, Yoshinori Sato <ysato@users.sourceforge.jp>, Hirokazu Takata <takata@linux-m32r.org>, linuxsh-shmedia-dev@lists.sourceforge.net, linux-m68k@vger.kernel.org, Ivan Kokshaysky <ink@jurassic.park.msu.ru>, Richard Henderson <rth@twiddle.net>, Chris Zankel <chris@zankel.net>, dev-etrax@axis.com, ultralinux@vger.kernel.org, Andi Kleen <ak@suse.de>, linuxsh-dev@lists.sourceforge.net, linux390@de.ibm.com, Russell King <rmk@arm.linux.org.uk>, parisc-linux@parisc-linux.org, akpm@osdl.org, Stephen Hemminger <shemminger@osdl.org>

Noticed by Rune Torgersen.

fix generic_fls64().
tcp_cubic is using fls64().

Signed-off-by: Akinobu Mita <mita@miraclelinux.com>

 include/linux/bitops.h |    2 +-
 1 files changed, 1 insertion(+), 1 deletion(-)

Index: 2.6-git/include/linux/bitops.h
=================================--- 2.6-git.orig/include/linux/bitops.h
+++ 2.6-git/include/linux/bitops.h
@@ -81,7 +81,7 @@ static inline int generic_fls64(__u64 x)
 {
 	__u32 h = x >> 32;
 	if (h)
-		return fls(x) + 32;
+		return fls(h) + 32;
 	return fls(x);
 }
 
