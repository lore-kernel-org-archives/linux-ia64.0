From: Jesse Barnes <jbarnes@sgi.com>
Date: Wed, 04 Dec 2002 01:11:46 +0000
Subject: Re: [Linux-ia64] 2.5.45 with CONFIG_NUMA=y
Message-Id: <marc-linux-ia64-105590709805500@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805486@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805486@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, Nov 27, 2002 at 05:22:04PM +0100, Xavier Bru wrote:
>  > > . Current settings for DIG are : 512MB/bank, 16GB/node,(mmzone.h)  but our
>  > > platform can support 64 GB/node (Even with less memory, bios maps
>  > > each node memory modulo 64GB). 
>  > > As it has been cleanly coded :-), we just changed DIG_BANKSHIFT to 31 
>  > > (2GB banks) and system runs. 
>  > > Should these values bee incremented in the future ?
>  > 
>  > Maybe that should be an option for the kernel configuration system?
> 
> This should be OK for us.

Wanna come up with a patch? :)  It could just be something like 'MB per
bank' or somesuch, only visible when DIG and DISCONTIG are turned on.

> Seems that we use the VGA mode through /dev/mem (No driver is actually 
> loaded). 
> Are there some known problems with /dev/mem and DISCONTIG_MEM ? 

I don't think there are discontig mem issues really, but platform issues
possibly.  On our platform for example, X might go looking in /dev/mem
for a list of PCI cards and then use the info in the PCI config space
incorrectly (e.g. IRQ values).  Other platforms probably have this issue
too, not sure about yours though.

> Do you think we should have more chances validating Frame buffer support and the
> card driver ? (I think platform has no AGP support).

Possibly.  I know that some of the frame buffer drivers were written to
expect the card to be uninitialized so that they'll work on non-x86
platforms.

Jesse

