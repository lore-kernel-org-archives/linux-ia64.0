From: Christoph Hellwig <hch@infradead.org>
Date: Sat, 04 Sep 2004 11:15:37 +0000
Subject: Re: [PATCH 2/4] SGI Altix cross partition functionality (1st revision)
Message-Id: <20040904121537.A14239@infradead.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040616163514.GB27891@sgi.com>
In-Reply-To: <20040616163514.GB27891@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> Please no magic numbers in logs.  This always leads to customers calling
> support with the "what does 13 mean and should I be concerned"?  If the
> community objects to the case statement above, then find a different
> way that implements the textual name.

So run a postprocessor over the log.

> I like keeping the lock protecting as little as possible.  This has been
> drilled into peoples heads here at SGI since the early Cray days.  We have
> always been told to keep locks protecting a single cohesive group of data.

And because of that IRIX isa huge mess with far too much locks :)  Keep
it as simple as possible and optimize where optimization is needed.
Needless complexity is the root of all evil.

