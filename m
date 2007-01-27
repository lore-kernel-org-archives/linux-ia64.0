From: Len Brown <lenb@kernel.org>
Date: Sat, 27 Jan 2007 06:55:17 +0000
Subject: Re: [PATCH 1/3] - Altix: ACPI SSDT PCI device support
Message-Id: <200701270155.18596.lenb@kernel.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20061115152454.6047.64973.sendpatchset@attica.americas.sgi.com> <20070126171048.5f0bf293.akpm@osdl.org>
In-Reply-To: <20070126171048.5f0bf293.akpm@osdl.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Andrew Morton <akpm@osdl.org>
Cc: John Keller <jpk@sgi.com>, linux-acpi@vger.kernel.org, tony.luck@intel.com, linux-ia64@vger.kernel.org, pcihpd-discuss@lists.sourceforge.net, gregkh@suse.de, linux-kernel@vger.kernel.org, ayoung@sgi.com, jes@sgi.com, "Starikovskiy, Alexey" <alexey.y.starikovskiy@linux.intel.com>

On Friday 26 January 2007 20:10, Andrew Morton wrote:
> On Wed, 15 Nov 2006 09:24:54 -0600
> John Keller <jpk@sgi.com> wrote:
> 
> > Add SN platform support for running with an ACPI
> > capable PROM that defines PCI devices in SSDT
> > tables. There is a SSDT table for every occupied
> > slot on a root bus, containing info for every
> > PPB and/or device on the bus. The SSDTs will be
> > dynamically loaded/unloaded at hotplug enable/disable.
> 
> An additional 600kb of diff has just popped up in the ACPI tree, so none of
> this patch applies any more.  I'll need to drop it again, sorry.
> 
> It's been over two months - I'm not sure why things are so difficult for
> this patchset.

it is because
1. this didn't make it into 2.6.20 before -rc1, and Linus prohibits adding features thereafter
2. these patches simultaneously depend on ACPI, hotplug, and IA64 platform dependent code,
    so it isn't always clear who owns them.  However, if Greg and Tony Ack them,
    I'll be happy to carry them upstream with the ACPI tree.

I'll reply to this note with a shim patch to help these apply, and a  pair of refreshed SGI patches
that apply on top of the ACPI tree.  Build tested vs sn2_defconfig , but SGI will have to test it on hardware.

thanks,
-Len
