From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Date: Tue, 16 Aug 2005 19:59:00 +0000
Subject: Re: [PATCH] IDE: don't offer IDE_GENERIC on ia64
Message-Id: <1124223946.22924.4.camel@localhost.localdomain>
List-Id: <linux-ia64.vger.kernel.org>
References: <200508111424.43150.bjorn.helgaas@hp.com>
	 <200508151507.22776.bjorn.helgaas@hp.com>
	 <58cb370e050816023845b57a74@mail.gmail.com>
	 <200508161316.32602.bjorn.helgaas@hp.com>
In-Reply-To: <200508161316.32602.bjorn.helgaas@hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Bjorn Helgaas <bjorn.helgaas@hp.com>
Cc: Bartlomiej Zolnierkiewicz <bzolnier@gmail.com>, B.Zolnierkiewicz@elka.pw.edu.pl, linux-kernel@vger.kernel.org, linux-ide@vger.kernel.org, linux-ia64@vger.kernel.org

> >   * non-functional HDIO_REGISTER_HWIF ioctl (ain't really working either)
> 
> HDIO_SCAN_HWIF - I don't know about this one.  How are we supposed to
> follow the "new ports shouldn't define IDE_ARCH_OBSOLETE_INIT" injunction
> if we lose all this functionality without it?  ia64 is about as close to
> a new port as you get :-)

It allows you to register interfaces from user space.

As to IDE_ARCH_OBOSOLETE_INIT, its a red herring. It's not worth the
trouble to avoid it given the expected short remaining life time of the
old IDE layer. Far better would be to help get the new SATA layer doing
PATA so drivers/ide can be deleted.

> IDE on ia64 is little-used, so I'm OK with leaving it alone, but
> I do think it's wrong for an architecture with no real restriction
> to specify MAX_HWIFS in ide.h.  Better to have the config option,
> and make the default there larger if necessary.

In the ideal world - its a historical inheritance that its not dynamic -
you probably should set it to 10 though - just for plug in IDE cards.


