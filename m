From: Robin Holt <holt@sgi.com>
Date: Sun, 05 Sep 2004 11:45:13 +0000
Subject: Re: [PATCH 2/4] SGI Altix cross partition functionality (1st revision)
Message-Id: <20040905114513.GA429@lnx-holt.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040616163514.GB27891@sgi.com>
In-Reply-To: <20040616163514.GB27891@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Sat, Sep 04, 2004 at 11:35:11AM -0500, Russ Anderson wrote:
> Christoph Hellwig wrote:
> > 
> > > I like keeping the lock protecting as little as possible.  This has been
> > > drilled into peoples heads here at SGI since the early Cray days.  We have
> > > always been told to keep locks protecting a single cohesive group of data.
> > 
> > Keep it as simple as possible and optimize where optimization is needed.
> > Needless complexity is the root of all evil.
> 
> IMHO, Dean's code is simple and not complex.  There is a lock per channel.
> What's so complex about that?
> 
> Dean's code> + for (ch_number = 0; ch_number < XPC_NCHANNELS; ch_number++) {
> Dean's code> +         sema_init(&xpc_registrations[ch_number].sema, 1);  /* mutex */
> Dean's code> + }
> 
...
> 
> What Dean is doing, and what the Cray and SGI people have learned over
> the last couple decades of hard work, is that it is simpler and less complex 
> to design in fine grain locks to avoid scaling problems.  We know that CPUs 
> will get faster, the number of CPUs will increase, as will the number of nodes 
> and amount of memory.  And as they increase, we know that big locks will get 
> hot and need to broken up.  So that is why you will find people that
> believe that it is simpler and less complex to design in fine grain locks,
> to avoid having to track down and fix scaling bugs.  

I would add that I think a lock that is protecting a channel is clearer to
understand than a lock per partition protecting all the channels in it.  When
I look at the partition structure and see a lock for the channels, I would,
at first glance, assume it is protecting addition or removal of the channels.

I remember someone once saying "Speaking clearly is saying what the other
person understands."  I think that applies here.

Robin
