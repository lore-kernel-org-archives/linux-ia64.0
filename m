From: Andi Kleen <ak@suse.de>
Date: Wed, 10 Mar 2004 17:10:38 +0000
Subject: Re: [PATCH] clean up some ACPI IRQ conversions
Message-Id: <20040310171038.GA26688@wotan.suse.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <200403091619.04333.bjorn.helgaas@hp.com> <20040309235428.GA25936@wotan.suse.de> <200403100941.21934.bjorn.helgaas@hp.com>
In-Reply-To: <200403100941.21934.bjorn.helgaas@hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Bjorn Helgaas <bjorn.helgaas@hp.com>
Cc: Andi Kleen <ak@suse.de>, acpi-devel@lists.sourceforge.net, linux-ia64@vger.kernel.org, "Nakajima, Jun" <jun.nakajima@intel.com>, "Brown, Len" <len.brown@intel.com>

On Wed, Mar 10, 2004 at 09:41:21AM -0700, Bjorn Helgaas wrote:
> On Tuesday 09 March 2004 4:54 pm, Andi Kleen wrote:
> > > These changes (all together, not individually) have been built and
> > > booted on ia64 and built for i386.
> > 
> > The x86-64 changes look fine to me. I suppose you will submit them directly?
> > Before you do that I would appreciate it if you could at least compile
> > check x86-64 and fix any compile errors that may have been introduced.
> 
> "make defconfig" compiles and links OK with the x86-64 cross compiler.

Thanks.

> 
> I couldn't see a way to turn on CONFIG_PCI_USE_VECTOR.

It's disabled because the generic code is too i386 centric.

-Andi
