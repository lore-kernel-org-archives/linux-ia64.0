From: Bartlomiej Zolnierkiewicz <bzolnier@gmail.com>
Date: Tue, 16 Aug 2005 12:59:26 +0000
Subject: Re: [PATCH] IDE: don't offer IDE_GENERIC on ia64
Message-Id: <58cb370e050816055924852804@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200508111424.43150.bjorn.helgaas@hp.com>
	 <1123836012.22460.16.camel@localhost.localdomain>
	 <200508151507.22776.bjorn.helgaas@hp.com>
	 <58cb370e050816023845b57a74@mail.gmail.com>
	 <1124196958.17555.8.camel@localhost.localdomain>
In-Reply-To: <1124196958.17555.8.camel@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
Cc: Bjorn Helgaas <bjorn.helgaas@hp.com>, B.Zolnierkiewicz@elka.pw.edu.pl, linux-kernel@vger.kernel.org, linux-ide@vger.kernel.org, linux-ia64@vger.kernel.org

On 8/16/05, Alan Cox <alan@lxorguk.ukuu.org.uk> wrote:
> On Maw, 2005-08-16 at 11:38 +0200, Bartlomiej Zolnierkiewicz wrote:
> > * removing IDE_ARCH_OBSOLETE_INIT define has some implications,
> >   * non-functional ide-cs driver (but there is no PCMCIA on IA64?)
> 
> IA64 systems can support PCI->Cardbus/PCMCIA cards so they do actually
> need this support. They could also do with cardbus IDE support but that
> means a whole pile of patches still although the refcounting stuff means
> its a lot closer to doable now

Therefore we need to fix ide-cs driver first to get rid of ide_init_hwif_ports()
which should be trivial unless some PPC32 specific hooks need it
(ide_ppc_md.ide_init_hwif).

> >   * ordering change for ide-pnp interfaces in case of no IDE devices
> >     on default IDE PCI ports, (but there aren't any ide-pnp devices on IA64?)
> 
> No ISAPnP

Excellent!

Bartlomiej
