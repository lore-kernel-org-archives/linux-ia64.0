From: Robin Holt <holt@sgi.com>
Date: Wed, 01 Sep 2004 10:19:15 +0000
Subject: Re: [PATCH 2/4] SGI Altix cross partition functionality (1st revision)
Message-Id: <20040901101914.GB12074@lnx-holt.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040616163514.GB27891@sgi.com>
In-Reply-To: <20040616163514.GB27891@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> > > +	case xpcMsgReceived:		return "xpcMsgReceived";
> > > +	case xpcMsgDelivered:		return "xpcMsgDelivered";
> > 
> > Please don't add strerror-lookalikes to the kernel.
> 
...
> 
> If you meant the former: XPC makes dev_info() calls to indicate that a
> channel to a partition has connected and disconnected (and why). The why
> is a reason code mapped to an ASCII string. Would you prefer that we put
> out a numeric value as opposed to a more meaningful ASCII string?

Please no magic numbers in logs.  This always leads to customers calling
support with the "what does 13 mean and should I be concerned"?  If the
community objects to the case statement above, then find a different
way that implements the textual name.

> 
> 
> > > +	for (ch_number = 0; ch_number < XPC_NCHANNELS; ch_number++) {
> > > +		sema_init(&xpc_registrations[ch_number].sema, 1);  /* mutex */
> > > +	}
> > 
> > A single mutex wouldn't do it?  It doesn't exactly look like it's used in
> > fast-paths
> 
> Yeah, you're right it's not a fast-path and a single mutex would work.
> I kind of like putting the lock within the data structure it's protecting.
> When you get the lock, you've already got the data of interest in your
> cache (obviously this depends on the size of the structure and where in
> the structure the data you're interested in resides). We're not talking
> about very much memory lost because of this. (The way it is we only end
> up with a total of two semaphores, instead of just one.)

I like keeping the lock protecting as little as possible.  This has been
drilled into peoples heads here at SGI since the early Cray days.  We have
always been told to keep locks protecting a single cohesive group of data.

Just my 2 cents.

Thanks,
Robin
