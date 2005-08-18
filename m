From: Stephane Eranian <eranian@hpl.hp.com>
Date: Thu, 18 Aug 2005 23:41:26 +0000
Subject: Re: Simulator bootloader fails with gcc 4
Message-Id: <20050818234126.GA5373@frankl.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20050720053139.GC13188@cse.unsw.EDU.AU>
In-Reply-To: <20050720053139.GC13188@cse.unsw.EDU.AU>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Fri, Aug 19, 2005 at 09:14:56AM +1000, Peter Chubb wrote:
> >>>>> "Stephane" = Stephane Eranian <eranian@hpl.hp.com> writes:
> 
> Stephane> The simulator is not using the regular memcpy() routine it
> Stephane> has its own custom routine (which is not named memcpy).
> 
> This is a stupid suggestion, but...
> 
>      Can you try recompiling the simulator with gcc 4.0, and see if
>      the problem is still there?  If a gcc 4.0-compiled simulator that
>      fixes the problem, and still allows booting of kernels compiled
>      with icc, gcc-2.96, etc., etc., can be released, then we're done.
> 
Does this problem happen with the x86 and/or ia64 ski version when bootloader
is compiled with gcc-4.0?

I can certainly try to compile ski with gcc-4.0. Could anyone of you
send me his .config file to make sure we have comparable kernels.

Thanks.


-- 
-Stephane
