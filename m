From: Robin Holt <holt@sgi.com>
Date: Mon, 07 Aug 2006 17:27:00 +0000
Subject: Re: Silent data corruption caused by XPC.
Message-Id: <20060807172700.GA24663@lnx-holt.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060807154608.GC15674@lnx-holt.americas.sgi.com>
In-Reply-To: <20060807154608.GC15674@lnx-holt.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Mon, Aug 07, 2006 at 08:57:51AM -0700, Luck, Tony wrote:
> > and verified it works.  I also added DBUG_ON statements to help catch
> > this if a similar situation is encountered.
> 
> Can you just do this once at alloc time rather than at every use?

Dean and I liked the idea at first, but hashed it over more.  My intent
with putting them right before the bte_copy was to trap the event where
a copy was going to be initiated that would corrupt memory.  If I put
them at allocation time only, any changes in the allocation would not
necessarily be caught.  I think we would like to leave them where they
are at unless you have a strong objection.  They are DBUG_ON() instead
of BUG_ON() so they should not have a performance impact normally.

If you would like it moved to allocation time, it will make
the patch smaller and more clean as we will move it into
xpc_kmalloc_cacheline_aligned.  Dean said he will handle that if you
desire.

Thanks,
Robin
