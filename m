From: Jesse Barnes <jbarnes@sgi.com>
Date: Tue, 10 Dec 2002 01:33:59 +0000
Subject: [Linux-ia64] Re: Configurable NUMA node memory size
Message-Id: <marc-linux-ia64-105590709805530@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Erich, could you please check out the discontig bits (mmzone.h) in the
SN update patch I posted today?  I renamed DIG_BANKSHIFT to just
BANKSHIFT so it could be reused, but I'm not sure if I did it correctly.

Thanks,
Jesse

On Mon, Dec 09, 2002 at 01:15:49PM +0100, Erich Focht wrote:
> Hi,
> 
> following the requests from Xavier and Jesse I introduced a
> configuration parameter for the maximum memory per NUMA node. The
> DIG_BANKSHIFT is set accordingly, the current choices are:
>          512MB/bank:  16GB/node,
>         2048MB/bank:  64GB/node,
>         8192MB/bank: 256GB/node.
> 
> The patch is for 2.5.50+ia64. Please consider applying it.
> 
> Thanks,
> Erich



