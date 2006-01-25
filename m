From: mita@miraclelinux.com (Akinobu Mita)
Date: Wed, 25 Jan 2006 11:26:25 +0000
Subject: [PATCH 0/6] RFC: use include/asm-generic/bitops.h
Message-Id: <20060125112625.GA18584@miraclelinux.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org
Cc: Richard Henderson <rth@twiddle.net>, Ivan Kokshaysky <ink@jurassic.park.msu.ru>, Russell King <rmk@arm.linux.org.uk>, Ian Molton <spyro@f2s.com>, dev-etrax@axis.com, David Howells <dhowells@redhat.com>, Yoshinori Sato <ysato@users.sourceforge.jp>, Linus Torvalds <torvalds@osdl.org>, linux-ia64@vger.kernel.org, Hirokazu Takata <takata@linux-m32r.org>, linux-m68k@vger.kernel.org, Greg Ungerer <gerg@uclinux.org>, linux-mips@linux-mips.org, parisc-linux@parisc-linux.org, linuxppc-dev@ozlabs.org, linux390@de.ibm.com, linuxsh-dev@lists.sourceforge.net, linuxsh-shmedia-dev@lists.sourceforge.net, sparclinux@vger.kernel.org, ultralinux@vger.kernel.org, Miles Bader <uclinux-v850@lsi.nec.co.jp>, Andi Kleen <ak@suse.de>, Chris Zankel <chris@zankel.net>

Large number of boilerplate bit operations written in C-language
are scattered around include/asm-*/bitops.h.
These patch series gather them into include/asm-generic/bitops.h. And

- kill duplicated code and comment (about 4000lines)
- use better C-language equivalents
- help porting new architecture (now include/asm-generic/bitops.h is not
  referenced from anywhere)

