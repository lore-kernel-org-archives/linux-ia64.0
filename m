From: Robin Holt <holt@sgi.com>
Date: Mon, 14 Feb 2005 16:33:31 +0000
Subject: Re: [PATCH] Convert pgtable cache to slab
Message-Id: <20050214163331.GA8576@lnx-holt.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <yq1wtxnprkq.fsf@wilson.mkp.net>
In-Reply-To: <yq1wtxnprkq.fsf@wilson.mkp.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Fri, Feb 11, 2005 at 01:33:51PM -0600, Robin Holt wrote:
> On Fri, Feb 11, 2005 at 10:51:12AM -0800, Luck, Tony wrote:
...
> > Making the slab node aware is probably the right thing to do, but
> > making quicklists node aware is less invasive.
> 
> Does anybody have a preference?
> 
> I sort of like the quicklist because they are more clear.  I think the
> node-aware slab cache may be quicker for some workloads..  On the SGI
> kernel based upon 2.4, we collapsed the quicklists into a single list
> and then just checked to see if the page being added to the list was for
> this node.  It prevented some problems, but resulted in some of our MPI
> loads keeping the quicklist completely full on most nodes and constantly
> draining/allocating from a single node.  My preference leans towards the
> slab cache, but I can be easily swayed.

I have given this some more thought over the weekend and think I am
leaning more towards the quicklists.  Its main attraction to me seems
to be the simplicity of design.  The quicklists remain consistent with
what we are already familiar with.  To make pte, pmd, and pgd entries
equivalent, I think I am going to propose a single quicklist for all
the different types of entries with a single add/remove function.

The single quicklist is probably going to prove helpful for the trim
functions.  Right now, the trim function tends to trim with a strong bias
towards the first cpu that processes the tick followed by a weaker bias
for the pte entries remaining on the list.  While the second bias seems
reasonable, collapsing to a single list eliminates that bias and then
making the trim only remove when the node is in a low memory situation
and only have it trim based upon some factor of available memory on the
node will significantly reduce the bias for first cpu to receive the tick.

Sorry for the confusing ramble, but I am in full Monday morning mode
right now.

Thanks,
Robin
