From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date: Wed, 10 Mar 2004 16:41:21 +0000
Subject: Re: [PATCH] clean up some ACPI IRQ conversions
Message-Id: <200403100941.21934.bjorn.helgaas@hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200403091619.04333.bjorn.helgaas@hp.com> <20040309235428.GA25936@wotan.suse.de>
In-Reply-To: <20040309235428.GA25936@wotan.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: acpi-devel@lists.sourceforge.net, linux-ia64@vger.kernel.org, Andi Kleen <ak@suse.de>, "Nakajima, Jun" <jun.nakajima@intel.com>, "Brown, Len" <len.brown@intel.com>

On Tuesday 09 March 2004 4:54 pm, Andi Kleen wrote:
> > These changes (all together, not individually) have been built and
> > booted on ia64 and built for i386.
> 
> The x86-64 changes look fine to me. I suppose you will submit them directly?
> Before you do that I would appreciate it if you could at least compile
> check x86-64 and fix any compile errors that may have been introduced.

"make defconfig" compiles and links OK with the x86-64 cross compiler.

I couldn't see a way to turn on CONFIG_PCI_USE_VECTOR.

