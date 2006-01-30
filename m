From: "David S. Miller" <davem@davemloft.net>
Date: Mon, 30 Jan 2006 23:02:44 +0000
Subject: Re: [parisc-linux] Re: [PATCH 3/6] C-language equivalents of
Message-Id: <20060130.150244.81476469.davem@davemloft.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060129071242.GA24624@miranda.arrow>
	<20060130170647.GC3816@linux-mips.org>
	<20060130195004.GA25860@miranda.arrow>
In-Reply-To: <20060130195004.GA25860@miranda.arrow>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: sdbrady@ntlworld.com
Cc: ralf@linux-mips.org, grundler@parisc-linux.org, mita@miraclelinux.com, linux-kernel@vger.kernel.org, ink@jurassic.park.msu.ru, spyro@f2s.com, dev-etrax@axis.com, dhowells@redhat.com, ysato@users.sourceforge.jp, torvalds@osdl.org, linux-ia64@vger.kernel.org, takata@linux-m32r.org, linux-m68k@vger.kernel.org, gerg@uclinux.org, linux-mips@linux-mips.org, parisc-linux@parisc-linux.org, linuxppc-dev@ozlabs.org, linux390@de.ibm.com, linuxsh-dev@lists.sourceforge.net, linuxsh-shmedia-dev@lists.sourceforge.net, sparclinux@vger.kernel.org, ultralinux@vger.kernel.org, uclinux-v850@lsi.nec.co.jp, ak@suse.de, chris@zankel.net

From: Stuart Brady <sdbrady@ntlworld.com>
Date: Mon, 30 Jan 2006 19:50:04 +0000

> Shame about popc on SPARC.  However, ffz is cheese, regardless of pops.
> (On sparc64, ffs is too.)  I'll wait for the generic bitops patches to
> be dealt with (or not) and then submit a patch fixing this if needed.

I'm happy with any improvement you might make here, for sure.

The sparc64 ffz() implementation was done so dog stupid like that
so that the code would be small since this gets inlined all over
the place.

So if you can keep it small and improve it, or make it a bit larger
and uninline it, that's great.
