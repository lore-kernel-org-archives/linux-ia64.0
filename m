From: Ian Molton <spyro@f2s.com>
Date: Wed, 25 Jan 2006 23:25:34 +0000
Subject: Re: [PATCH 3/6] C-language equivalents of include/asm-*/bitops.h
Message-Id: <43D808EE.9040906@f2s.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060125112625.GA18584@miraclelinux.com> <20060125113206.GD18584@miraclelinux.com> <20060125200250.GA26443@flint.arm.linux.org.uk>
In-Reply-To: <20060125200250.GA26443@flint.arm.linux.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Russell King <rmk+lkml@arm.linux.org.uk>
Cc: Akinobu Mita <mita@miraclelinux.com>, linux-kernel@vger.kernel.org, Richard Henderson <rth@twiddle.net>, Ivan Kokshaysky <ink@jurassic.park.msu.ru>, dev-etrax@axis.com, David Howells <dhowells@redhat.com>, Yoshinori Sato <ysato@users.sourceforge.jp>, Linus Torvalds <torvalds@osdl.org>, linux-ia64@vger.kernel.org, Hirokazu Takata <takata@linux-m32r.org>, linux-m68k@vger.kernel.org, Greg Ungerer <gerg@uclinux.org>, linux-mips@linux-mips.org, parisc-linux@parisc-linux.org, linuxppc-dev@ozlabs.org, linux390@de.ibm.com, linuxsh-dev@lists.sourceforge.net, linuxsh-shmedia-dev@lists.sourceforge.net, sparclinux@vger.kernel.org, ultralinux@vger.kernel.org, Miles Bader <uclinux-v850@lsi.nec.co.jp>, Andi Kleen <ak@suse.de>, Chris Zankel <chris@zankel.net>

Russell King wrote:

> This code generates more expensive shifts than our (ARMs) existing C
> version.  This is a backward step.
> 
> Basically, shifts which depend on a variable are more expensive than
> constant-based shifts.

arm26 will have the same problem here.

