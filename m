From: Jack Steiner <steiner@sgi.com>
Date: Fri, 30 Jul 2004 14:45:47 +0000
Subject: Re: Timer updates revision 7 (asm sets predicates/various fixes)
Message-Id: <20040730144547.GB2621@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.58.0407292044500.3633@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.58.0407292044500.3633@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> New Code:
> 
> singsing:/usr/src/noship-tests # ./dmt
> gettimeofday cycles: 3312 212 213 213 212 212 213 213 213 213
> clock_gettime(REAL) cycles: 2880 224 210 210 210 210 210 210 210 210
> clock_gettime(MONO) cycles: 285 233 226 219 219 219 219 219 219 219
> 
> singsing:/usr/src/noship-tests # ./todscale
>  CPUS       WALL  WALL/CPUS
>     1      0.187      0.187
>     2      0.746      0.373


The new code certainly is faster, but does it scale at high cpu counts?

The numbers above indicate a substantial slowdown going from 1 to 2 
cpus. What happens at higher cpu counts.


-- 
Thanks

Jack Steiner (steiner@sgi.com)          651-683-5302
Principal Engineer                      SGI - Silicon Graphics, Inc.


