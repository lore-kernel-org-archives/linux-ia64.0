From: Alex Williamson <alex.williamson@hp.com>
Date: Mon, 13 Sep 2004 20:02:40 +0000
Subject: Re: [PATCH] 2.6.9-rc1 Ia64 build broken due to HPET
Message-Id: <1095105760.20631.57.camel@tdi>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040910041200.GN5668@cse.unsw.EDU.AU>
In-Reply-To: <20040910041200.GN5668@cse.unsw.EDU.AU>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Sat, 2004-09-11 at 15:26 -0600, Alex Williamson wrote:

>    Yes, all the sx1000 based boxes should have one.  I'll try to get a
> newer glibc on one and run the test program again, unless someone beats
> be to it.


  Here's the test program output (running on an rx7620) with 2.6.9-rc2
built on a sles9 system:

          Gettimeofday() = 1095104931.812600000
           CLOCK_REALTIME= 1095104931.812639404 resolution= 3712.000240992
          CLOCK_MONOTONIC=        369.103451704 resolution= 3712.000240992
 CLOCK_PROCESS_CPUTIME_ID=          0.000782450 resolution= 0.000000001
  CLOCK_THREAD_CPUTIME_ID=          0.000794115 resolution= 0.000000001


-- 
Alex Williamson                             HP Linux & Open Source Lab

