From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Date: Fri, 29 Jul 2005 06:27:52 +0000
Subject: RE: Delete scheduler SD_WAKE_AFFINE and SD_WAKE_BALANCE flags
Message-Id: <200507290627.j6T6Rrg06842@unix-os.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
In-Reply-To: <42E98DEA.9090606@yahoo.com.au>
References: <200507282308.j6SN8Tg01993@unix-os.sc.intel.com>
In-Reply-To: <200507282308.j6SN8Tg01993@unix-os.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: 'Nick Piggin' <nickpiggin@yahoo.com.au>
Cc: Ingo Molnar <mingo@elte.hu>, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org

Nick Piggin wrote on Thursday, July 28, 2005 7:01 PM
> Chen, Kenneth W wrote:
> >Well, that's exactly what I'm trying to do: make them not aggressive
> >at all by not performing any load balance :-)  The workload gets maximum
> >benefit with zero aggressiveness.
> 
> Unfortunately we can't forget about other workloads, and we're
> trying to stay away from runtime tunables in the scheduler.


This clearly outlines an issue with the implementation.  Optimize for one
type of workload has detrimental effect on another workload and vice versa.


> If we can get performance to within a couple of tenths of a percent
> of the zero balancing case, then that would be preferable I think.

I won't try to compromise between the two.  If you do so, we would end up
with two half baked raw turkey.  Making less aggressive load balance in the
wake up path would probably reduce performance for the type of workload you
quoted earlier and for db workload, we don't want any of them at all, not
even the code to determine whether it should be balanced or not.

Do you have an example workload you mentioned earlier that depends on
SD_WAKE_BALANCE?  I would like to experiment with it so we can move this
forward instead of paper talk.

- Ken

