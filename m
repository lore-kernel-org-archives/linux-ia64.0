From: Christoph Hellwig <hch@infradead.org>
Date: Sat, 04 Sep 2004 11:12:57 +0000
Subject: Re: [PATCH 2/4] SGI Altix cross partition functionality (1st revision)
Message-Id: <20040904121257.D14123@infradead.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040616163514.GB27891@sgi.com>
In-Reply-To: <20040616163514.GB27891@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> > Why do you have three different option when the only way they're usefull
> > is to have all three enabled at the same time.
> 
> By this I asssume you mean that rather than having both IA64_SGI_SN_XPC
> and IA64_SGI_SN_XPNET, we should have just one, like IA64_SGI_SN_XP, that
> causes all the parts to get built. Correct?

Yes.

> > > +	case xpcMsgReceived:		return "xpcMsgReceived";
> > > +	case xpcMsgDelivered:		return "xpcMsgDelivered";
> > 
> > Please don't add strerror-lookalikes to the kernel.
> 
> I'm not clear on this. Do you mean ditch xpc_get_ascii_reason_code()
> altogether and have no mapping of a numeric reason code to an ASCII
> string?

Yes.  strerror() is entirely userspace policy.

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

Well, Linux is difficult.  First rule of thumb is keep it simple, and
if you ever need a fastpath semaphore you're better of making it a separate
entinity from the registration sempahore.

