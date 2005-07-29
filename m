From: Nick Piggin <nickpiggin@yahoo.com.au>
Date: Fri, 29 Jul 2005 08:48:07 +0000
Subject: Re: Delete scheduler SD_WAKE_AFFINE and SD_WAKE_BALANCE flags
Message-Id: <42E9ED47.1030003@yahoo.com.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <200507290627.j6T6Rrg06842@unix-os.sc.intel.com>
In-Reply-To: <200507290627.j6T6Rrg06842@unix-os.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Cc: Ingo Molnar <mingo@elte.hu>, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org

Chen, Kenneth W wrote:
> Nick Piggin wrote on Thursday, July 28, 2005 7:01 PM

> This clearly outlines an issue with the implementation.  Optimize for one
> type of workload has detrimental effect on another workload and vice versa.
> 

Yep. That comes up fairly regularly when tuning the scheduler :(

> 
> I won't try to compromise between the two.  If you do so, we would end up
> with two half baked raw turkey.  Making less aggressive load balance in the
> wake up path would probably reduce performance for the type of workload you
> quoted earlier and for db workload, we don't want any of them at all, not
> even the code to determine whether it should be balanced or not.
> 

Well, that remains to be seen. If it can be made _smarter_, then you
may not have to take such a big compromise.

But either way, there will have to be some compromise made. At the
very least you have to find some acceptable default.

> Do you have an example workload you mentioned earlier that depends on
> SD_WAKE_BALANCE?  I would like to experiment with it so we can move this
> forward instead of paper talk.
> 

Well, you can easily see suboptimal scheduling decisions on many
programs with lots of interprocess communication. For example, tbench
on a dual Xeon:

processes    1               2               3              4

2.6.13-rc4:  187, 183, 179   260, 259, 256   340, 320, 349  504, 496, 500
no wake-bal: 180, 180, 177   254, 254, 253   268, 270, 348  345, 290, 500

Numbers are MB/s, higher is better.

Networking or other IO workloads where processes are tightly coupled
to a specific adapter / interrupt source can also see pretty good
gains.

-- 
SUSE Labs, Novell Inc.

Send instant messages to your online friends http://au.messenger.yahoo.com 
