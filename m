From: Ralf Baechle <ralf@linux-mips.org>
Date: Mon, 30 Jan 2006 17:06:47 +0000
Subject: Re: [parisc-linux] Re: [PATCH 3/6] C-language equivalents of include/asm-*/bitops.h
Message-Id: <20060130170647.GC3816@linux-mips.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060125112625.GA18584@miraclelinux.com> <20060125113206.GD18584@miraclelinux.com> <20060125200250.GA26443@flint.arm.linux.org.uk> <20060126000618.GA5592@twiddle.net> <20060126085540.GA15377@flint.arm.linux.org.uk> <20060126161849.GA13632@colo.lackof.org> <20060126164020.GA27222@flint.arm.linux.org.uk> <20060126230443.GC13632@colo.lackof.org> <20060126230353.GC27222@flint.arm.linux.org.uk> <20060129071242.GA24624@miranda.arrow>
In-Reply-To: <20060129071242.GA24624@miranda.arrow>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Stuart Brady <sdbrady@ntlworld.com>
Cc: Grant Grundler <grundler@parisc-linux.org>, Akinobu Mita <mita@miraclelinux.com>, linux-kernel@vger.kernel.org, Ivan Kokshaysky <ink@jurassic.park.msu.ru>, Ian Molton <spyro@f2s.com>, dev-etrax@axis.com, David Howells <dhowells@redhat.com>, Yoshinori Sato <ysato@users.sourceforge.jp>, Linus Torvalds <torvalds@osdl.org>, linux-ia64@vger.kernel.org, Hirokazu Takata <takata@linux-m32r.org>, linux-m68k@vger.kernel.org, Greg Ungerer <gerg@uclinux.org>, linux-mips@linux-mips.org, parisc-linux@parisc-linux.org, linuxppc-dev@ozlabs.org, linux390@de.ibm.com, linuxsh-dev@lists.sourceforge.net, linuxsh-shmedia-dev@lists.sourceforge.net, sparclinux@vger.kernel.org, ultralinux@vger.kernel.org, Miles Bader <uclinux-v850@lsi.nec.co.jp>, Andi Kleen <ak@suse.de>, Chris Zankel <chris@zankel.net>

On Sun, Jan 29, 2006 at 07:12:42AM +0000, Stuart Brady wrote:

> On MIPS, fls() and flz() should probably use CLO.

It actually uses clz.

> Curiously, MIPS is the only arch with a flz() function.

No longer.  The fls implementation was based on flz and fls was the only
user of flz.  So I cleaned that, once I commit flz will be gone.  Not
only a cleanup but also a minor optimization.

  Ralf
