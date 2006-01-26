From: Richard Henderson <rth@twiddle.net>
Date: Thu, 26 Jan 2006 17:30:14 +0000
Subject: Re: [PATCH 3/6] C-language equivalents of include/asm-*/bitops.h
Message-Id: <20060126173014.GC5592@twiddle.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060125112625.GA18584@miraclelinux.com> <20060125113206.GD18584@miraclelinux.com> <20060125200250.GA26443@flint.arm.linux.org.uk> <20060126000618.GA5592@twiddle.net> <20060126053412.0da7f505.froese@gmx.de>
In-Reply-To: <20060126053412.0da7f505.froese@gmx.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Edgar Toernig <froese@gmx.de>
Cc: Akinobu Mita <mita@miraclelinux.com>, linux-kernel@vger.kernel.org, Ivan Kokshaysky <ink@jurassic.park.msu.ru>, Ian Molton <spyro@f2s.com>, dev-etrax@axis.com, David Howells <dhowells@redhat.com>, Yoshinori Sato <ysato@users.sourceforge.jp>, Linus Torvalds <torvalds@osdl.org>, linux-ia64@vger.kernel.org, Hirokazu Takata <takata@linux-m32r.org>, linux-m68k@vger.kernel.org, Greg Ungerer <gerg@uclinux.org>, linux-mips@linux-mips.org, parisc-linux@parisc-linux.org, linuxppc-dev@ozlabs.org, linux390@de.ibm.com, linuxsh-dev@lists.sourceforge.net, linuxsh-shmedia-dev@lists.sourceforge.net, sparclinux@vger.kernel.org, ultralinux@vger.kernel.org, Miles Bader <uclinux-v850@lsi.nec.co.jp>, Andi Kleen <ak@suse.de>, Chris Zankel <chris@zankel.net>

On Thu, Jan 26, 2006 at 05:34:12AM +0100, Edgar Toernig wrote:
> Why shift at all?

Becuase that *is* a valid architecture tuning knob.  Most risc
machines can't AND with arbitrary constants like that, and loading
the constant might bulk things up more than just using the shift.


r~
