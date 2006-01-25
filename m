From: Brent Casavant <bcasavan@sgi.com>
Date: Wed, 25 Jan 2006 17:45:04 +0000
Subject: RE: [PATCH] SN2 user-MMIO CPU migration
Message-Id: <20060125113959.H16092@chenjesu.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060118163305.Y42462@chenjesu.americas.sgi.com>
In-Reply-To: <20060118163305.Y42462@chenjesu.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, 25 Jan 2006, Chen, Kenneth W wrote:

> Thought everyone agreed to call the sync function with the new task context,
> (after ia64_switch_to). Something changed which made you changed your mind?

Yeah.  I mentioned this in my other message, but I kept running into
invalid accesses (and migration/swapper threads dying) in sn_migrate()
when the sync was done after ia64_switch_to().  Any idea what I might
be doing wrong?  Perhaps I need to call barrier() first?

> diff --git a/include/asm-ia64/thread_info.h b/include/asm-ia64/thread_info.h
> > @@ -46,6 +47,7 @@ struct thread_info {
> >  	.exec_domain	= &default_exec_domain,	\
> >  	.flags		= 0,			\
> >  	.cpu		= 0,			\
> > +	.last_cpu	= 0,			\
> >  	.addr_limit	= KERNEL_DS,		\
> >  	.preempt_count	= 0,			\
> >  	.restart_block = {			\
> 
> Looked spurious, init_task has static initializer, which will have zero
> initial value automatically.

I was just following the existing mechanism in the code (obviously
I'm not the only one to add "= 0" in here.

I can submit a separate cleanup patch for this and quite a bit of other
code if you'd like.  I've run into all sorts of 80-column/etc issues
while working on this, but didn't want to mix cleanup with meatier
changes.

Brent

-- 
Brent Casavant                          All music is folk music.  I ain't
bcasavan@sgi.com                        never heard a horse sing a song.
Silicon Graphics, Inc.                    -- Louis Armstrong
