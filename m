From: Doug Chapman <doug.chapman@hp.com>
Date: Mon, 30 Jul 2007 13:42:07 +0000
Subject: Re: panic from vector domain patch (was RE: Linus' tree broken?)
Message-Id: <1185802927.10381.0.camel@athlon>
List-Id: <linux-ia64.vger.kernel.org>
References: <1185239265.19353.6.camel@phobos>
In-Reply-To: <1185239265.19353.6.camel@phobos>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Mon, 2007-07-30 at 05:56 -0400, Jes Sorensen wrote:
> >>>>> "Doug" = Doug Chapman <doug.chapman@hp.com> writes:
> 
> Doug> Kenji,
> 
> Doug> Yes, this does fix the problem.  My system is booting just fine
> Doug> with this patch.
> 
> Doug,
> 
> Just back from vacation - with this patch I don't see the crash
> either. I do however still see the hang in the boot scripts - wonder
> if we still have an overflow somewhere.
> 
> I'll do some more digging.....
> 
> Cheers,
> Jes
> 

Jes,

FYI, booting for me just fine on a RHEL5 installed base.  What distro
were you booting on?

- Doug


