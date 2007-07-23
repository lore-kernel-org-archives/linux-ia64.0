From: Doug Chapman <doug.chapman@hp.com>
Date: Mon, 23 Jul 2007 17:21:45 +0000
Subject: Re: Linus' tree broken?
Message-Id: <1185211305.7158.15.camel@dchapman.boston.redhat.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <46A4B026.9030307@sgi.com>
In-Reply-To: <46A4B026.9030307@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Mon, 2007-07-23 at 15:41 +0200, Jes Sorensen wrote:
> Hi,
> 
> Have anyone else had seen issues with the Linus git tree failing to
> boot? I'm trying a pull as of this morning and it seems to hang when
> it's brining up the ethernet devices.
> 
> It's not locking up, just the boot scripts never continues - happens
> both on SLES10 and FC7 roots :(
> 
> Just wanted to check before spending real time on it.
> 
> Cheers,
> Jes
> -

Jes,

Doesn't boot for me either but I think I am seeing a different issue.  I
hit a panic very early in bootup:

16 CPUs available, 16 CPUs total
MCA related initialization done
kernel unaligned access to 0xffffffffffffffff, ip=0xa0000001007f1511
swapper[0]: error during unaligned kernel access
 -1 [1]
Modules linked in:


About to dig into this more deeply now.

- Doug


