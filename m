From: "Mallick, Asit K" <asit.k.mallick@intel.com>
Date: Wed, 23 Jul 2003 04:40:02 +0000
Subject: RE: [PATCH] don't use ld.bias
Message-Id: <marc-linux-ia64-105893522123205@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105883179830025@msgid-missing>
In-Reply-To: <marc-linux-ia64-105883179830025@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

It does make sense to not use the ld.bias in the spinlock, it will make
more cacheline bouncing in a larger SMP system.
Thanks,
Asit


> -----Original Message-----
> From: Jesse Barnes [mailto:jbarnes@sgi.com] 
> Sent: Tuesday, July 22, 2003 6:12 AM
> To: Chen, Kenneth W
> Cc: linux-ia64@vger.kernel.org; davidm@hpl.hp.com
> Subject: Re: [PATCH] don't use ld.bias
> 
> 
> On Mon, Jul 21, 2003 at 05:15:39PM -0700, Chen, Kenneth W wrote:
> > > Patch to fix spin_lock to not use ld.bias since it causes 
> a bunch of
> > bus
> > > activity that hurts scalability when a lock is contended.
> > 
> > It's dangerous to say something without knowing the whole 
> context, but I
> > can't resist asking why not fix the contended lock area 
> instead?  Sounds
> > like you have some serious contention.
> 
> Maybe I shouldn't have said 'contended'.  This causes 
> problems even when
> a lock is nearly uncontended.  I agree that fixing lock 
> contention is a
> good idea, but as I read this code, it'll only make the very best case
> (totally uncontended) only a little better than if the 
> ld.bias were just
> an ld and it makes the average and contended cases _much_ worse.
> 
> I can get some data if you're not convinced by reading the code :)
> 
> Thanks,
> Jesse
> -
> To unsubscribe from this list: send the line "unsubscribe 
> linux-ia64" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
