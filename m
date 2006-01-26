From: Russell King <rmk+lkml@arm.linux.org.uk>
Date: Thu, 26 Jan 2006 08:55:41 +0000
Subject: Re: [PATCH 3/6] C-language equivalents of include/asm-*/bitops.h
Message-Id: <20060126085540.GA15377@flint.arm.linux.org.uk>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060125112625.GA18584@miraclelinux.com> <20060125113206.GD18584@miraclelinux.com> <20060125200250.GA26443@flint.arm.linux.org.uk> <20060126000618.GA5592@twiddle.net>
In-Reply-To: <20060126000618.GA5592@twiddle.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Akinobu Mita <mita@miraclelinux.com>, linux-kernel@vger.kernel.org, Ivan Kokshaysky <ink@jurassic.park.msu.ru>, Ian Molton <spyro@f2s.com>, dev-etrax@axis.com, David Howells <dhowells@redhat.com>, Yoshinori Sato <ysato@users.sourceforge.jp>, Linus Torvalds <torvalds@osdl.org>, linux-ia64@vger.kernel.org, Hirokazu Takata <takata@linux-m32r.org>, linux-m68k@vger.kernel.org, Greg Ungerer <gerg@uclinux.org>, linux-mips@linux-mips.org, parisc-linux@parisc-linux.org, linuxppc-dev@ozlabs.org, linux390@de.ibm.com, linuxsh-dev@lists.sourceforge.net, linuxsh-shmedia-dev@lists.sourceforge.net, sparclinux@vger.kernel.org, ultralinux@vger.kernel.org, Miles Bader <uclinux-v850@lsi.nec.co.jp>, Andi Kleen <ak@suse.de>, Chris Zankel <chris@zankel.net>

On Wed, Jan 25, 2006 at 04:06:18PM -0800, Richard Henderson wrote:
> On Wed, Jan 25, 2006 at 08:02:50PM +0000, Russell King wrote:
> > > +	s = 16; if (word << 16 != 0) s = 0; b += s; word >>= s;
> > > +	s =  8; if (word << 24 != 0) s = 0; b += s; word >>= s;
> > > +	s =  4; if (word << 28 != 0) s = 0; b += s; word >>= s;
> ...
> > Basically, shifts which depend on a variable are more expensive than
> > constant-based shifts.
> 
> Actually, they're all constant shifts.  Just written stupidly.

Unfortunately that's not correct.  You do not appear to have checked
the compiler output like I did - this code does _not_ generate
constant shifts.

-- 
Russell King
 Linux kernel    2.6 ARM Linux   - http://www.arm.linux.org.uk/
 maintainer of:  2.6 Serial core
