From: Robin Holt <holt@sgi.com>
Date: Wed, 02 Nov 2005 13:26:39 +0000
Subject: Re: [RFC] 4-level page table directories.
Message-Id: <20051102132639.GA22123@lnx-holt.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20051027041709.GA13193@attica.americas.sgi.com>
In-Reply-To: <20051027041709.GA13193@attica.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Assuming I am using the right numbers as indicated below, I have seen
no measurable performance change with 4-levels.

> Begin of SingleRandomAccess section.
> Main table size   = 2^27 = 134217728 words
> Number of updates = 536870912
> CPU time used  = 107.997328 seconds
> Real time used = 108.077732 seconds
> 0.004967452 Billion(10^9) Updates    per second [GUP/s]
> Found 0 errors in 134217728 locations (passed).
> Node(s) with error 0
> Node selected 0
> Single GUP/s 0.004967
> Current time (1130893857) is Tue Nov  1 19:10:57 2005
> 
> End of SingleRandomAccess section.

For my real testing, I doubled the dataset size.  The person who helped
me setup the first benchmark had assumed the system only had 1GB per cpu.
I changed that to 2GB.  I was not sure which "time used" was the one
of concern, but neither showed any difference outside the noise range.
I repeated 10 runs, each takes about 6 minutes.  I will attach the whole
information below.

I also created a tweak on Jack's vhpt_miss timing test.  I changed it
so it drags twice the cache-size worth of data through the processor
between each reference to a group of pages spaced through the users
address space at PAGE_SIZE * 2048 * 2048 steps.  This was intended to
show the cost of the stall while loading the extra page table level.
This has likewise showed the cost in the noise range.  The min-to-max
spread of 100 timings of 16,000 references in the loop with large
memset in the middle was 681 mSec for 3-level and 682 mSec for 4-level.
Average time was 2 mSec higher which places it easily within the noise.

I am not sure what other tests people would want run.  I have thrown every
benchmark I know how to run against this.  The more I think through it,
the less concerned I am with adding the extra page table level.  For the
vast majority of applications I think we are talking about consuming an
extra three cache lines.

I base this upon the assertion that the majority of applications only
reference stuff in regions 1,2, and 3.  Since one PGD entry will cover
the entire portion of the address space, we will simply add a single,
frequently used, cacheline to the lookup chain for the vhpt_miss and
page_fault code path.  The only time that will change is when a larger
virtual address space is used and then it is the desired behavior.

Does anybody have any objections to making 4 level the default?

The timings I promised to attached were on a machine which was just
imaged again so I lost my data file.  I will attach those once another
pass is complete.  Sorry for the delay.

Thanks,
Robin
