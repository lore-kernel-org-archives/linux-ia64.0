From: Russ Anderson <rja@sgi.com>
Date: Sat, 04 Sep 2004 16:35:11 +0000
Subject: Re: [PATCH 2/4] SGI Altix cross partition functionality (1st revision)
Message-Id: <200409041635.i84GZBdO010008@ben.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040616163514.GB27891@sgi.com>
In-Reply-To: <20040616163514.GB27891@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Christoph Hellwig wrote:
> 
> > I like keeping the lock protecting as little as possible.  This has been
> > drilled into peoples heads here at SGI since the early Cray days.  We have
> > always been told to keep locks protecting a single cohesive group of data.
> 
> Keep it as simple as possible and optimize where optimization is needed.
> Needless complexity is the root of all evil.

IMHO, Dean's code is simple and not complex.  There is a lock per channel.
What's so complex about that?

Dean's code> + for (ch_number = 0; ch_number < XPC_NCHANNELS; ch_number++) {
Dean's code> +         sema_init(&xpc_registrations[ch_number].sema, 1);  /* mutex */
Dean's code> + }

Perhaps I'm missing what you mean by "complexity".  I understand that a reasonable
way to modify a mono-CPU kernel to run on a dual-CPU system is to add a big
kernel lock.  And that as the number of CPUs increase, the locks need to be
finer grain to avoid excessive lock contention.  And that identifying and
breaking up the hot locks is a part of that process.  Cray went through
that process with COS, unicos, SGI with Irix, and now the community
with Linux.

What Dean is doing, and what the Cray and SGI people have learned over
the last couple decades of hard work, is that it is simpler and less complex 
to design in fine grain locks to avoid scaling problems.  We know that CPUs 
will get faster, the number of CPUs will increase, as will the number of nodes 
and amount of memory.  And as they increase, we know that big locks will get 
hot and need to broken up.  So that is why you will find people that
believe that it is simpler and less complex to design in fine grain locks,
to avoid having to track down and fix scaling bugs.  

Thanks,
-- 
Russ Anderson, OS RAS/Partitioning Project Lead  
SGI - Silicon Graphics Inc          rja@sgi.com
