From: Chuck Fleckenstein <cfleck@co.intel.com>
Date: Wed, 08 Nov 2000 10:06:48 +0000
Subject: Re: [Linux-ia64] re-enabling interrupts and interrupt collect
Message-Id: <marc-linux-ia64-105590678205670@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Since the ssm of psr.i does not require serialization then I believe this
would
be expected.

so as you said the guaranteed method of safely reenabling ic and i would
be:

    ssm psr.ic
    ;;
    srlz.d
    ssm psr.i


Chuck


Jonathan Case Nicklin wrote:

> All,
>
> Recently, i was working on a section of code that disabled/enable
> interrupts
> and interrupt collection like so.
>
>     rsm psr.i | psr.ic
>     ;;
>     ... //body
>     ;;
>     ssm psr.i | psr.ic
>     ;;
>     srlz.d
>     ;;
>
> I found however that this implementation did not work under heavy loads.
>
> It took a while to figure out that a pending interrupt that had occurred
>
> in the body of code, executed while interrupts were turned off, was
> delivered
> after the ssm call as expected. However, it was delivered before the ic
> bit
> serialized. In the code this caused undesirable results. I found that
> the
> proper way to implement the above is to re-enable the ic bit and
> serialize
> before re-enabling the interrupt bit. Has anyone else come across this
> problem and can anybody shed some light on whether this is the expected
> operation.
>
> Sincerely,
> Jonathan Case Nicklin
>
> Mission Critical Linux
> www.missioncriticallinux.com
>
> ps. The manual gives an example of the implementation that works, but
> does
> not provide any explanation of implementation itself (as far as I can
> see ;-P )
>
> _______________________________________________
> Linux-IA64 mailing list
> Linux-IA64@linuxia64.org
> http://lists.linuxia64.org/lists/listinfo/linux-ia64


