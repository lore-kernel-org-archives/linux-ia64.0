From: Alex Williamson <alex.williamson@hp.com>
Date: Thu, 09 Sep 2004 15:55:03 +0000
Subject: Re: Timer patch V8
Message-Id: <1094745303.24754.5.camel@tdi>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.58.0408092115500.22817@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.58.0408092115500.22817@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, 2004-09-09 at 08:28 -0700, Christoph Lameter wrote:
> On Thu, 9 Sep 2004, Alex Williamson wrote:
> 
> > On Wed, 2004-09-08 at 16:23 -0700, Christoph Lameter wrote:
> > > Sorry. I was too superficial when looking at this issue. The following
> > > patch makes the hpet driver build again but I do not have a machine here
> > > that would allow me to test this. Could you verify that this works and get
> > > back to me?
> > >
> >
> >    It builds and boots, so a definite improvement.  I'm not sure how to
> > check if the hpet is being used though.  Thanks,
> 
> Could you run the following program and sent me the output? The precision
> of the REALTIME clock should be the same as the HPET device.
> 

The program reports:

          Gettimeofday() = 1094745228.671790000
           CLOCK_REALTIME=     -17032.000003664 resolution= 3648.000238936
          CLOCK_MONOTONIC=     -17032.000003664 resolution= 3648.000238936
 CLOCK_PROCESS_CPUTIME_ID=          0.000714263 resolution= 0.000000001
  CLOCK_THREAD_CPUTIME_ID=          0.000723913 resolution= 0.000000001


The HPET driver reported a 4ns tick on the timer.  Thanks,

	Alex

-- 
Alex Williamson                             HP Linux & Open Source Lab

