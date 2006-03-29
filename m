From: Zoltan Menyhart <Zoltan.Menyhart@bull.net>
Date: Wed, 29 Mar 2006 13:37:34 +0000
Subject: Re: accessed/dirty bit handler tuning
Message-Id: <442A8D9E.4040409@bull.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <44157CF1.5060902@bull.net>
In-Reply-To: <44157CF1.5060902@bull.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Chen, Kenneth W wrote:

> Oh my gosh, my worst nightmare becomes the reality, :-( It is unacceptable
> to have srlz.d in vhpt_miss.

Can you please explain why it is a nightmare?
How much time do you think will be wasted?

>  Couple of alternatives:
>
> (1) strip off all ptc.g related instructions in vhpt and just let the hpw
>     walker do the job.  Kernel can take double faults, but after all, with
>     what people do to ia64 kernel, this might be the best solution.

I do not really see why it would be more efficient to let the walker do
the inserting job, once we are in the "vhpt_miss" handler.

If we suffer from the delay, why could the walker avoid this overhead?

Have you got a prototype for this reduced "vhpt_miss" handler ?

> (2) add 20 cycles of delay in front of ptc.g

I do not think any delay like this could be safe.

> (3) dynamically patch out srlz.d for McK/Madison/Montecito processor.

Is it specified anywhere what CPU models do / do not require this "srlz.d"?

Thanks,

Zoltan
