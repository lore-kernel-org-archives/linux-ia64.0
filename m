From: Zoltan Menyhart <Zoltan.Menyhart@bull.net>
Date: Tue, 27 Sep 2005 13:46:40 +0000
Subject: Re: Using Cpusets with HyperThreads
Message-Id: <43394D40.5070602@bull.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <20050923000016.2cc416ac.pj@sgi.com>
In-Reply-To: <20050923000016.2cc416ac.pj@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> do we need to accommodate a more generic specification? e.g how about
> a system with K sockets per node, L cores per socket and M threads per
> core?  And if that's not complicated enough, how about a really large
> system where K, L and/or M are not necessarily constant?

I think it is a good idea to be able to handle the general case.

The appropriate shift and mask values could be dynamically established
at the boot time.
This could allow us to maintain a single kernel for machines with
different (generations of) processors.

Obviously, having more choice than just between the A and B sides,
we need some more rich set of options for the CPUsets, like:

- I need N out of M cores of the sockets x...y
  + I want to prevent the other applications from using the rest of
    the cores
- I need the max. number of CPUs which are not farer from each
  other than X
  + Use as many cores, as the HW can provide with Y memory bandwidth
    for each 

I think we should add the "locality information" into

/sys/devices/system/node/node<x>

like:

/sys/devices/system/node/node<x>/socket<y>/core<z>/cpu<n>

For compatibility reason we can keep the entries like:

/sys/devices/system/node/node<x>/cpu<n>

Thanks,

Zoltan Menyhart
