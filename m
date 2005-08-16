From: Bartlomiej Zolnierkiewicz <bzolnier@gmail.com>
Date: Tue, 16 Aug 2005 13:49:20 +0000
Subject: Re: [PATCH] IDE: don't offer IDE_GENERIC on ia64
Message-Id: <58cb370e05081606497e4d9907@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200508111424.43150.bjorn.helgaas@hp.com>
	 <1123836012.22460.16.camel@localhost.localdomain>
	 <200508151507.22776.bjorn.helgaas@hp.com>
	 <58cb370e050816023845b57a74@mail.gmail.com>
	 <1124196958.17555.8.camel@localhost.localdomain>
	 <20050816134029.GA5113@parcelfarce.linux.theplanet.co.uk>
In-Reply-To: <20050816134029.GA5113@parcelfarce.linux.theplanet.co.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Matthew Wilcox <matthew@wil.cx>
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>, Bjorn Helgaas <bjorn.helgaas@hp.com>, B.Zolnierkiewicz@elka.pw.edu.pl, linux-kernel@vger.kernel.org, linux-ide@vger.kernel.org, linux-ia64@vger.kernel.org

On 8/16/05, Matthew Wilcox <matthew@wil.cx> wrote:
> On Tue, Aug 16, 2005 at 01:55:58PM +0100, Alan Cox wrote:
> > On Maw, 2005-08-16 at 11:38 +0200, Bartlomiej Zolnierkiewicz wrote:
> > > * removing IDE_ARCH_OBSOLETE_INIT define has some implications,
> > >   * non-functional ide-cs driver (but there is no PCMCIA on IA64?)
> >
> > IA64 systems can support PCI->Cardbus/PCMCIA cards so they do actually
> > need this support. They could also do with cardbus IDE support but that
> > means a whole pile of patches still although the refcounting stuff means
> > its a lot closer to doable now
> 
> Then IDE_ARCH_OBSOLETE_INIT needs to be added back for all other
> architectures that support PCI too ...

Rather ide-cs needs to be fixed to use ide_std_init_ports() instead of
ide_init_hwif_ports() (please see my reply to Alan).

Bartlomiej
