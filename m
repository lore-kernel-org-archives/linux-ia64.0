From: Alex Williamson <alex.williamson@hp.com>
Date: Mon, 13 Sep 2004 22:44:11 +0000
Subject: Re: [PATCH] 2.6.9-rc1 Ia64 build broken due to HPET
Message-Id: <1095115451.20631.120.camel@tdi>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040910041200.GN5668@cse.unsw.EDU.AU>
In-Reply-To: <20040910041200.GN5668@cse.unsw.EDU.AU>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Mon, 2004-09-13 at 15:22 -0700, Christoph Lameter wrote:
> On Mon, 13 Sep 2004, Alex Williamson wrote:
> 
> > So, first and foremost, the ITC interpolator is broken for any ITC
> > greater than 1GHz.  Secondary, the HPET interpolator comes in too late,
> > and the code doesn't really seem to be able to support that.
> 
> Well. This means that the resolution is broken for any clock > 1GHZ.
> 

   Yep, and the patch below at least fixes that much:

          Gettimeofday() = 1095114506.777214000
           CLOCK_REALTIME= 1095114506.777283285 resolution= 0.000000001
          CLOCK_MONOTONIC=        188.577379016 resolution= 0.000000001
 CLOCK_PROCESS_CPUTIME_ID=          0.000864731 resolution= 0.000000001
  CLOCK_THREAD_CPUTIME_ID=          0.000883450 resolution= 0.000000001


> The hpet interpolator is in a module? or is it compiled into the kernel?

   Compiled in.  Here's what it looks like in dmesg (with some debug
printks added):

PAL Information Facility v0.5
perfmon: added sampling format default_format
perfmon_default_smpl: default_format v2.0 registered
time_interpolator_resolution() time_interpolator->frequency = 1200000000
register_posix_clock(0,...) res = 1
register_posix_clock(1,...) res = 1
Total HugeTLB memory allocated, 0
SGI XFS with large block/inode numbers, no debug enabled
Initializing Cryptographic API
GSI 18 (level, high) -> CPU 1 (0x0801) vector 71
GSI 19 (level, high) -> CPU 2 (0x0000) vector 72
GSI 20 (level, high) -> CPU 3 (0x0800) vector 73
hpet0: at MMIO 0xc0000ffffc082000, IRQs 71, 72, 73
hpet0: 4ns tick, 3 64-bit timers
GSI 122 (level, high) -> CPU 0 (0x0001) vector 74
GSI 123 (level, high) -> CPU 1 (0x0801) vector 75
GSI 124 (level, high) -> CPU 2 (0x0000) vector 76
hpet1: at MMIO 0xc0000ffffc002000, IRQs 74, 75, 76
hpet1: 4ns tick, 3 64-bit timers
register_time_interpolator() using this timer
EFI Time Services Driver v0.4

> register_time_interpolator allows a later registration of a time
> interpolator. The question though is: Will it win against the one
> already installed. It may win if you specify a smaller drift than the ITC
> interpolator. Gotta look at that.

   Yes, it does win, so apparently the drift is smaller (I only put in
enough printks so see that it won).  But the HPET interpolator is still
coming in after init_posix_timers(), so the monotonic and realtime
resolution isn't going to be updated to match the new timer without an
additional hook in there.  Thanks,

	Alex

-- 
Alex Williamson                             HP Linux & Open Source Lab

