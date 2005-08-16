From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Date: Tue, 16 Aug 2005 13:42:00 +0000
Subject: Re: [PATCH] IDE: don't offer IDE_GENERIC on ia64
Message-Id: <1124201152.17555.36.camel@localhost.localdomain>
List-Id: <linux-ia64.vger.kernel.org>
References: <200508111424.43150.bjorn.helgaas@hp.com>
	 <20050811203437.GA9265@infradead.org>
	 <58cb370e050816030248e6283c@mail.gmail.com>
In-Reply-To: <58cb370e050816030248e6283c@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Bartlomiej Zolnierkiewicz <bzolnier@gmail.com>
Cc: Christoph Hellwig <hch@infradead.org>, Bjorn Helgaas <bjorn.helgaas@hp.com>, B.Zolnierkiewicz@elka.pw.edu.pl, linux-kernel@vger.kernel.org, linux-ide@vger.kernel.org, linux-ia64@vger.kernel.org

On Maw, 2005-08-16 at 12:02 +0200, Bartlomiej Zolnierkiewicz wrote:
> On 8/11/05, Christoph Hellwig <hch@infradead.org> wrote:
> > On Thu, Aug 11, 2005 at 02:24:43PM -0600, Bjorn Helgaas wrote:
> > > IA64 boxes only have PCI IDE devices, so there's no need to blindly poke
> > > around in I/O port space.  Poking at things that don't exist causes MCAs
> > > on HP ia64 systems.
> > 
> > Maybe it should instead depend on those systems where it is available.
> > Anything but X86?
> 
> Don't forget that arch specific drivers use IDE_GENERIC *indirectly*
> to probe for devices.

Just about everything wants IDE GENERIC. Most of them want the probe
address providing function to simply be "return 0" or the two 'magic'
PCI bus legacy addresses. Probably only ia-32 wants to poke other
addresses and even that now checks for non-PCI first

