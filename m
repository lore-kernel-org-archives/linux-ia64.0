From: James Bottomley <James.Bottomley@SteelEye.com>
Date: Tue, 06 Mar 2007 18:01:00 +0000
Subject: Re: [parisc-linux] [PATCH 1/2] Use a weak symbol for the empty
Message-Id: <1173204060.3379.28.camel@mulgrave.il.steeleye.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1173193568.89821.610708199943.qpush@concordia>
In-Reply-To: <1173193568.89821.610708199943.qpush@concordia>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Michael Ellerman <michael@ellerman.id.au>
Cc: Greg Kroah-Hartman <greg@kroah.com>, linux-mips@linux-mips.org, dev-etrax@axis.com, linux-ia64@vger.kernel.org, discuss@x86-64.org, chris@zankel.net, dhowells@redhat.com, linuxppc-dev@ozlabs.org, linux-m68k@vger.kernel.org, ink@jurassic.park.msu.ru, gerg@uclinux.org, sparclinux@vger.kernel.org, uclinux-v850@lsi.nec.co.jp, linux-pci@atrey.karlin.mff.cuni.cz, parisc-linux@parisc-linux.org, kernel@wantstofly.org, rth@twiddle.net

On Tue, 2007-03-06 at 16:06 +0100, Michael Ellerman wrote:
> I'm not sure if this is going to fly, weak symbols work on the compilers I'm
> using, but whether they work for all of the affected architectures I can't say.
> I've cc'ed as many arch maintainers/lists as I could find.

Well, for your use, PCI already uses weak symbols, so it must work on
every architecture that you want to do it on ...

James


