From: Jesse Barnes <jbarnes@sgi.com>
Date: Tue, 26 Nov 2002 18:33:50 +0000
Subject: Re: [Linux-ia64] 2.5.45 with CONFIG_NUMA=y
Message-Id: <marc-linux-ia64-105590709805487@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805486@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805486@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, Nov 26, 2002 at 06:54:36PM +0100, Xavier Bru wrote:
> 
> Hi,
> 
> Booting the 2.5.45 kernel on our numa platform, we hit 2 problems:
> 
> . Current settings for DIG are : 512MB/bank, 16GB/node,(mmzone.h)  but our
> platform can support 64 GB/node (Even with less memory, bios maps
> each node memory modulo 64GB). 
> As it has been cleanly coded :-), we just changed DIG_BANKSHIFT to 31 
> (2GB banks) and system runs. 
> Should these values bee incremented in the future ?

Maybe that should be an option for the kernel configuration system?

> . We can't get X11 working (Xserver loops in user mode). Note that 
> it works OK with 2.5.45 without DISCONTIG_MEM set. Having a look to the
> mappings in /proc/ and the XFree86 log, we saw no difference. Any idea 
> ?

Does X initialize your card correctly?  I know that scanning /dev/mem
for video cards (which is what XFree86 does, IIRC) can be problematic on
some platforms...

Jesse

