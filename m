From: Christoph Hellwig <hch@infradead.org>
Date: Sun, 11 Jul 2004 10:11:27 +0000
Subject: Re: [PATCH 3/4] SGI Altix cross partition functionality
Message-Id: <20040711101127.GB11249@infradead.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040617183638.GA3712@sgi.com>
In-Reply-To: <20040617183638.GA3712@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, Jul 07, 2004 at 02:40:17PM -0500, Dean Nelson wrote:
> > +	memset((u8 *)&part->references + sizeof(part->references), 0,
> > 
> > cast to u8 * in memset? Ummm..
> 
> I'm not exactly sure what you're objecting to here. The cast is necessary for
> a correct result. The following two lines do not give the same result (the
> 'references' field is an atomic_t):

Actually I was misreading the code to see a simple case to (u8 *) of the
variable, but the actual code looks even more fishy now that I look in-depth
;-)

What about the readable variant:

memset(&part->nchannels, 0,
       sizeof(xpc_partition_t) - offsetoff(xpc_partition_t, nchannels));

