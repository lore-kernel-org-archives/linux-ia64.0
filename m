From: Christoph Hellwig <hch@infradead.org>
Date: Thu, 15 Jul 2004 21:00:04 +0000
Subject: Re: [PATCH 1/4] SGI Altix cross partition functionality
Message-Id: <20040715210004.GB10378@infradead.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040616163339.GA27891@sgi.com>
In-Reply-To: <20040616163339.GA27891@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, Jul 14, 2004 at 11:04:48AM -0500, Dean Nelson wrote:
> > bad idea.  I have patches to completely kill numnodes, don't try to
> > mess with it.  So far it's also completly an architecture-thing.
> 
> What are you planning to replace numnodes with?

A bitmap of online nodes once pj's nodemask_t is in.  That way the silly
distinctinon of nasid_t and cnodeid_t values in IP27 and SN2 code can go
away.

> XPC has two functions (xpc_allow_IPI_ops() and xpc_restrict_IPI_ops()) which
> need to change the protections governing IPI operations and AMO (memory)
> operations for each node in a partition. What mechanism are you proposing
> to allow one to iterate through all of the nodes in a partition?

I'm not exactly sure.  I'll look through once I get a little time.

