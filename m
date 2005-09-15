From: Zou Nan hai <nanhai.zou@intel.com>
Date: Thu, 15 Sep 2005 22:54:43 +0000
Subject: RE: Attribute spinlock contention ticks to caller.
Message-Id: <1126824883.2523.14.camel@linux-znh>
List-Id: <linux-ia64.vger.kernel.org>
References: <20050914222644.GA5036@lnx-holt.americas.sgi.com>
In-Reply-To: <20050914222644.GA5036@lnx-holt.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Fri, 2005-09-16 at 01:37, Luck, Tony wrote:
> >This also opens the door for people submitted other special cases.
> 
> I'm very sympathetic to getting better performance data.  I agree
> 100% that knowing who called spinlock contention is far better than
> just lumping all spinlock contention together.
> 
> But I have to agree with Stephane that this looks like the start
> of a slippery slope of special cases (each of which provides two
> new exported symbols).
> 
> We should look to see if there is a better way to flag address
> ranges in the kernel where you'd like to bill time to the caller
> rather than the function (perhaps some sort of tag table like the
> extable used for copyin/copyout fault recovery?  Then we can just
> export one table and have the profiler search it ... rather than
> a new pair of symbols for every case.
> 
> Or you can try to convince me that spinlock contention is such
> a special one off case, and we will never, ever, want to do this
> anywhere else.
> 
> -Tony

  There is a function in_lock_function in kernel/spinlock.c
  However in latest kernel, ia64_spinlock_contention is not in 
.spinlock.text section.
  We could first collect ia64_spinlock_contention into .spinlock.text
section. Then use in_lock_function.

Zou Nan hai
> -
> To unsubscribe from this list: send the line "unsubscribe linux-ia64" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

