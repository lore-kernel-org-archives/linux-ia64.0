From: Alex Williamson <alex_williamson@hp.com>
Date: Mon, 14 Apr 2003 14:52:43 +0000
Subject: Re: [Linux-ia64] zx2000  monitor
Message-Id: <marc-linux-ia64-105590723705494@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705491@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705491@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Matthew Wilcox wrote:
> 
> On Mon, Apr 14, 2003 at 04:27:34PM +0200, Adriano Galano wrote:
> > Hello:
> >
> > I received today one Itanium 2 workstation (HP zx2000, very heavy machine
> > :-)
> > But, I have a trouble I can't attached one VGA display. The connector in the
> > rear of the machine is some "strange", how could I connect my standard
> > monitor?
> 
> Is it the EVC connector, perhaps?  Here's one answer:
> http://bizforums.itrc.hp.com/cm/QuestionAnswer/1,,0x781636e69499d611abdb0090277a778c,00.html
> 

   Unlikely.  zx2000 requires a plugin graphics adapter.  Typically
this would be an AGP card in slot 2.  All the AGP cards available
with the system should have a standard 15 pin VGA connector and/or
a DVI connector.  If your graphics card only has DVI connectors,
you can get DVI to VGA converter cables.  These usually come with
the card.  AFAIK, EVC is/was only used on parisc hardware.

	Alex

--
Alex Williamson                             HP Linux & Open Source Lab

