From: Waiman Long <waiman.long@hpe.com>
Date: Tue, 14 Jun 2016 19:11:23 +0000
Subject: Re: [RFC PATCH-tip 2/6] locking/rwsem: Enable optional count-based spinning on reader
Message-Id: <576056DB.5050701@hpe.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1465927959-39719-1-git-send-email-Waiman.Long@hpe.com> <1465927959-39719-3-git-send-email-Waiman.Long@hpe.com> <20160614182757.GA15903@linux-80c1.suse>
In-Reply-To: <20160614182757.GA15903@linux-80c1.suse>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Davidlohr Bueso <dave@stgolabs.net>
Cc: Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>, linux-kernel@vger.kernel.org, x86@kernel.org, linux-alpha@vger.kernel.org, linux-ia64@vger.kernel.org, linux-s390@vger.kernel.org, linux-arch@vger.kernel.org, xfs@oss.sgi.com, Jason Low <jason.low2@hp.com>, Dave Chinner <david@fromorbit.com>, Scott J Norton <scott.norton@hpe.com>, Douglas Hatch <doug.hatch@hpe.com>

On 06/14/2016 02:27 PM, Davidlohr Bueso wrote:
> On Tue, 14 Jun 2016, Waiman Long wrote:
>
>> This patch provides a way for the kernel code to designate specific
>> rwsems to be more aggressive in term of optimistic spinning that the
>> writers will continue to spin for some additional count-based time to
>> see if it can get the lock before sleeping. This aggressive spinning
>> mode should only be used on rwsems where the readers are unlikely to
>> go to sleep.
>
> Yikes, exposing this sort of thing makes me _very_ uneasy, not to mention
> the ad-hoc nature and its easiness to mess up. I'm not really for 
> this, even
> if it shows extraordinary performance boosts on benchmarks.
>
> Thanks,
> Davidlohr

I understand your concern. I will see if there is a way to autotune 
instead of using explicit enablement.

Cheers,
Longman
