From: Grant Grundler <iod00d@hp.com>
Date: Wed, 19 Nov 2003 16:45:07 +0000
Subject: Re: [RFC] How drivers notice a MCA on I/O read? [1/3]
Message-Id: <marc-linux-ia64-106926030617030@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106915044130197@msgid-missing>
In-Reply-To: <marc-linux-ia64-106915044130197@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, Nov 18, 2003 at 07:11:20PM +0900, Hidetoshi Seto wrote:
...
> I want to convey the error to the offending driver, and want to enable the
> driver to retry failed read.

Hidetoshi,
Did you mean the driver literally "retry failed read" or did you mean
the driver could "recover" (ie return errors for pending IO requests)?

> So, I think about a readb_check function that has checking ability enable
> it return error value if MCA occur on read.
> Drivers could use readb_check instead of usual readb, and could diagnosis
> whether a retry be required or not, by the return value of readb_check.

I see little value in a simple retry. If the board is failing
(even transient failures) badly enough to cause MCA, it's probably
better to clean up driver state and stop accepting IO requests.

> To realize this, I consider following two plans:
> 
>  - readb_check on driver (with Notifier)
>     Outline:
>     - Platform specific MCA handler has a Notifier as hook point.
>     - Driver may register a hook function to the Notifier.
>     - Notifier calls over registered functions when MCA is signaled.
>     - Called hook function checks address of error, and if the error seems
>       to be concerned with the parent driver, ups internal error flag and
>       stops Notifier by returning OK.
>     - MCA handler regards state of Notifier, and decides the system to
>       resume or not.
>     - Restarted driver may refer the error flag after read, and may retry
>       the read if flag is up.

This sounds flexibile to enough to do something other than retry read.

I've been wondering if registering a callback at module_init() would be
sufficient. The callback could clean up driver state so the driver
instance can be shut down. Something like a Hotplug operation to remove
the card.
This way the driver wouldn't need a new read/write interface to
access MMIO space.

>     Feature:
>     - Generic kernel is not changed.
>     - Require a platform specific MCA handler.
>     - Service is available for platform specific drivers.
> 
>  -readb_check on kernel
>     Outline:
>     - Kernel has readb_check function.
>     - Drivers may use readb_check instead of usual readb.
>     - MCA handler checks address of error, and if it occurs in readb_check,
>       changes return value of readb_check and resumes interrupted context.
>     - Driver may refer the return value to notice MCA in last read procedure.
>     Feature:
>     - Generic kernel requires new codes.
>     - Require some codes in generic MCA procedure.
>     - Service is available for all drivers.
> 
> Which one is better?

I'm really not sure. Need to think about it more.

thanks,
grant
