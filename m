From: Rob Fowler <rjf@cs.rice.edu>
Date: Tue, 05 Apr 2005 20:43:30 +0000
Subject: Re: [Gelato-technical] Serious performance degradation on a RAID
Message-Id: <4252F872.1010900@cs.rice.edu>
List-Id: <linux-ia64.vger.kernel.org>
References: <16978.62532.841151.100745@napali.hpl.hp.com>
In-Reply-To: <16978.62532.841151.100745@napali.hpl.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

I've recently had discussions with several vendors who have mentioned
similar magnitudes of disk performance degradation due to the
coupling of vibration between cooling fans and disks.  This can 
dramatically increase seek time by keeping the arm from settling.
In one case, upgrading a chassis fan caused disk throughput to go down
by a factor of 16.  The solution is careful attention to vibration
damping in mountings.  Vibration caused by fan bearing wear could have
a similar effect.

Can you go back to your old kernel to verify that it is still
giving you the same performance?

-- Rob Fowler


David Mosberger wrote:
>>>>>>On Tue, 05 Apr 2005 20:11:51 +0200, Andreas Hirstius <Andreas.Hirstius@cern.ch> said:
> 
> 
>   Andreas> Hi, We have a rx4640 with 3x 3Ware 9500 SATA controllers
>   Andreas> and 24x WD740GD HDD in a software RAID0 configuration
>   Andreas> (using md).  With kernel 2.6.11 the read performance on the
>   Andreas> md is reduced by a factor of 20 (!!)  compared to previous
>   Andreas> kernels.  The write rate to the md doesn't change!! (it
>   Andreas> actually improves a bit).
> 
> Is there any reason to believe this change in behavior is
> ia64-specific?  I doubt it.  The q-syscollect profiles on your
> web-site shows that the CPU is basically completely idle.  You may
> want to try 2.6.10 to see whether the bad behavior was introduced
> before or after that.  Unfortunately, 2.6 is developing very rapidly
> so you may have to do more binary searching between 2.6.9 and 2.6.10
> or 2.6.10 and 2.6.11 to pin the problem down to a useful granularity.
> You may also want to look at the bitkeeper changelogs to see if you
> can find anything suspicious (you can do that easily via the web by
> browsing the source code [1]).  Lastly, you may want to ask on
> linux-kernel whether anybody can think of a change that could have
> this effect.
> 
> 	--david
> 
> [1] http://linux.bkbits.net:8080/linux-2.5/src?nav=index.html
> 
> _______________________________________________
> Gelato-technical mailing list
> Gelato-technical@gelato.unsw.edu.au
> https://www.gelato.unsw.edu.au/mailman/listinfo/gelato-technical
