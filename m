From: Christoph Hellwig <hch@infradead.org>
Date: Fri, 28 Oct 2005 22:37:09 +0000
Subject: Re: virtualization hooks patch for ia64 2.6.15
Message-Id: <20051028223709.GA13558@infradead.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <516F50407E01324991DD6D07B0531AD57E78CC@cacexc12.americas.cpqcorp.net>
In-Reply-To: <516F50407E01324991DD6D07B0531AD57E78CC@cacexc12.americas.cpqcorp.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Fri, Oct 28, 2005 at 01:51:24PM -0700, Magenheimer, Dan (HP Labs Fort Collins) wrote:
> Attached is a patch which provides a set of virtualization
> hooks for Linux/ia64.  Although these will be applicable
> for Xen, they are generalized to be useful for some other
> virtualization solutions.  In fact, all mentions of Xen
> (except for one comment) have been deleted; this is purely
> a foundation patch which adds a layer of indirection to
> certain C and assembly routines so that they can be easily
> replaced.  Until the hooks are used, this patch has no functional
> effect -- e.g. calls to foo() are changed to __foo() and then
> re-defined to foo().  Virtualization solutions need only
> add an ifdef'd include in one (new) header file to utilize
> the hooks and enable solution-specific paravirtualization.

This patch looks very nice to me.  But it doesn't make sense to apply
it without an actual paravirtualization backend, so could you please
submit a Xen/ia64 patch ontop ASAP?

