From: Jack Steiner <steiner@sgi.com>
Date: Thu, 15 Jul 2004 21:16:37 +0000
Subject: Re: [PATCH 1/4] SGI Altix cross partition functionality
Message-Id: <20040715211636.GA17102@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040616163339.GA27891@sgi.com>
In-Reply-To: <20040616163339.GA27891@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, Jul 15, 2004 at 10:00:04PM +0100, Christoph Hellwig wrote:
> On Wed, Jul 14, 2004 at 11:04:48AM -0500, Dean Nelson wrote:
> > > bad idea.  I have patches to completely kill numnodes, don't try to
> > > mess with it.  So far it's also completly an architecture-thing.
> > 
> > What are you planning to replace numnodes with?
> 
> A bitmap of online nodes once pj's nodemask_t is in.  That way the silly
> distinctinon of nasid_t and cnodeid_t values in IP27 and SN2 code can go
> away.


Can you explain your proposal a little more. 

The concept of nasid_t & cnodeid_t are different. A system can have a maximum
of 256 nodes (cnodeid_t 0..255), but the nasid values could
be 1536..2048. 

I'm not sure what you are proposing. Dont increase NR_NODES to 2048 -
some tables will get too big. Also, scanning bitmaps of 2048 bits is
more costly than scanning bitmaps of 256 elements. I havent checked
if this is a frequent operation, though....



> 
> > XPC has two functions (xpc_allow_IPI_ops() and xpc_restrict_IPI_ops()) which
> > need to change the protections governing IPI operations and AMO (memory)
> > operations for each node in a partition. What mechanism are you proposing
> > to allow one to iterate through all of the nodes in a partition?
> 
> I'm not exactly sure.  I'll look through once I get a little time.
> 
> -
> To unsubscribe from this list: send the line "unsubscribe linux-ia64" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

-- 
Thanks

Jack Steiner (steiner@sgi.com)          651-683-5302
Principal Engineer                      SGI - Silicon Graphics, Inc.


