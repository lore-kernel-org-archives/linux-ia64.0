From: Jesse Barnes <jbarnes@engr.sgi.com>
Date: Wed, 22 Sep 2004 23:23:54 +0000
Subject: Re: rename generic_defconfig to defconfig?
Message-Id: <200409221923.54839.jbarnes@engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200409221713.12673.jbarnes@engr.sgi.com>
In-Reply-To: <200409221713.12673.jbarnes@engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wednesday, September 22, 2004 7:02 pm, Bjorn Helgaas wrote:
> On Wednesday 22 September 2004 3:13 pm, Jesse Barnes wrote:
> > Just thought I'd float the idea of making the ia64 defconfig into a
> > generic ia64 kernel config.  It's probably easiest just to rename
> > generic_defconfig to defconfig since that already works everywhere (well,
> > except for akpm's box apparently).  That would make it extra easy to
> > build a working kernel for the various ia64 boxes out there...
>
> Sounds like a good idea to me.  If the idea is to make it as easy as
> possible to build working kernels, maybe we should also make some
> things static rather than modules.  For starters:
>
>  CONFIG_TULIP (HP superdome core I/O and 4-port cards)
>  CONFIG_E100  (i2000)
>  CONFIG_E1000 (Tiger)
>  CONFIG_USB_EHCI_HCD (HP boxes)
>  CONFIG_USB_OHCI_HCD (HP boxes)
>  CONFIG_USB_HID
>
> Or maybe I'm the only one who's too lazy to mess with modules
> for every build.

No, I think you have a point there :)  I *really* don't like having to copy 
modules over.  If tg3 isn't builtin yet, it would be nice too.

> I think generic_defconfig currently builds a McKinley kernel,
> which may be the right thing, but you do have to remember
> to switch back to CONFIG_ITANIUM for i2000.

Right, but those boxes are mainly for the masochists among us, so I think a 
McKinley setting is the right choice.

Jesse
