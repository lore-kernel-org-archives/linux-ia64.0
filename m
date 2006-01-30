From: "David S. Miller" <davem@davemloft.net>
Date: Mon, 30 Jan 2006 04:03:35 +0000
Subject: Re: [parisc-linux] Re: [PATCH 3/6] C-language equivalents of
Message-Id: <20060129.200335.69237695.davem@davemloft.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060126230443.GC13632@colo.lackof.org>
	<20060126230353.GC27222@flint.arm.linux.org.uk>
	<20060129071242.GA24624@miranda.arrow>
In-Reply-To: <20060129071242.GA24624@miranda.arrow>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: sdbrady@ntlworld.com
Cc: grundler@parisc-linux.org, mita@miraclelinux.com, linux-kernel@vger.kernel.org, ink@jurassic.park.msu.ru, spyro@f2s.com, dev-etrax@axis.com, dhowells@redhat.com, ysato@users.sourceforge.jp, torvalds@osdl.org, linux-ia64@vger.kernel.org, takata@linux-m32r.org, linux-m68k@vger.kernel.org, gerg@uclinux.org, linux-mips@linux-mips.org, parisc-linux@parisc-linux.org, linuxppc-dev@ozlabs.org, linux390@de.ibm.com, linuxsh-dev@lists.sourceforge.net, linuxsh-shmedia-dev@lists.sourceforge.net, sparclinux@vger.kernel.org, ultralinux@vger.kernel.org, uclinux-v850@lsi.nec.co.jp, ak@suse.de, chris@zankel.net

From: Stuart Brady <sdbrady@ntlworld.com>
Date: Sun, 29 Jan 2006 07:12:42 +0000

> There are versions of hweight*() for sparc64 which use POPC when
> ULTRA_HAS_POPULATION_COUNT is defined, but AFAICS, it's never defined.

That's right, the problem here is that no chips actually implement
the instruction in hardware, it is software emulated, ie. useless :-)
