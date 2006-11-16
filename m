From: "Luck, Tony" <tony.luck@intel.com>
Date: Thu, 16 Nov 2006 19:23:13 +0000
Subject: Re: [patch 4/4] ia64: fix allmodconfig build
Message-Id: <20061116192313.GA25317@intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200611160843.kAG8hCf3017752@shell0.pdx.osdl.net>
In-Reply-To: <200611160843.kAG8hCf3017752@shell0.pdx.osdl.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, Nov 16, 2006 at 11:08:21AM +0000, Alan wrote:
> >  config BLK_DEV_AMD74XX
> >  	tristate "AMD and nVidia IDE support"
> > +	depends on X86
> 
> NAK this part. The AMD74xx chipset also supports Alpha. I've no idea what
> the situation is with the Nvidia parts. It also goes against the general
> policy of building everything that can be built on each platform so as to
> find bugs/portability problems early.

Is the problem is with the driver? amd74xx.c uses pci_get_legacy_ide_irq(),
ia64 doesn't have this defined (and I don't think that creating such a function
would be right for ia64).

This is the only driver that uses pci_get_legacy_ide_irq ... is that a
red flag that it is doing something strange (or something that has been
superceeded by some other mechanism)?

I'll apply the other hunk (for simscsi).  Some bit of infiniband is
now also breaking allmodconfig, so it is not like this patch is the
only thing stopping allmodconfig from working.

-Tony
