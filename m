From: Andrew Morton <akpm@linux-foundation.org>
Date: Sun, 25 Mar 2007 09:20:44 +0000
Subject: Re: sata-vsc broken on SGI Prism
Message-Id: <20070325012044.97dc14fc.akpm@linux-foundation.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <je8xdnova3.fsf@sykes.suse.de>
In-Reply-To: <je8xdnova3.fsf@sykes.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Andreas Schwab <schwab@suse.de>
Cc: linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, jeff@garzik.org

On Sat, 24 Mar 2007 10:17:24 +0100 Andreas Schwab <schwab@suse.de> wrote:

> I'm getting this panic when loading sata-vsc on a SGI Prism:

With what kernel?

> Loading sata_vsc
> ACPI: Unable to derive IRQ for device 0001:00:03.0
> ACPI: PCI Interrupt 0001:00:03.0[A]: no GSI
> FRZ XN request short error. 
> FRZ XN error detail 1A:
> 	Command word: 0x11
> 	Supplemental: 0xff
> 	Source node id: 0x0
> 	Source chip id: 0x2
> 	Destination chip id: 0x0
> 	Data error: 0x0
> 	Echo: 0x70
> 	Valid: 0x0
> 	Address: 0x1802000021
> FRZ XN error detail 1B:
> 	Command word: 0x0
> 	Supplemental: 0x0
> 	Source node id: 0x0
> 	Source chip id: 0x0
> 	Destination chip id: 0x0
> 	Echo: 0x0
> 	Valid: 0x0
> 	Address: 0x0
> Fatal ICE HW error
> Kernel panic - not syncing: hub_eint_handler: Fatal TIO Error
> 
> Bisection has identified this patch (together with the follow-up patch to
> fix the compilation failure):
> 
> commit 7cbaa86b937b0b1fab95c159989f6a3c00bbcf78
> Author: Dan Wolstenholme <daniel@wolstenholme.net>
> Date:   Tue Jan 9 05:59:21 2007 -0500
> 
>     [libata] sata_vsc: support PCI MSI
>     
>     Signed-off-by: Jeff Garzik <jeff@garzik.org>
> 

It seems that little of that patch remains present in current mainline.
