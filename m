From: Matthew Wilcox <matthew@wil.cx>
Date: Thu, 22 Sep 2005 17:13:40 +0000
Subject: Re: [Lhms-devel] [PATCH 4/4] V4 ia64 SPARSEMEM - SPARSEMEM code changes
Message-Id: <20050922171340.GG26389@parisc-linux.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <1127406976.10664.52.camel@localhost>
In-Reply-To: <1127406976.10664.52.camel@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, Sep 22, 2005 at 09:36:16AM -0700, Dave Hansen wrote:
> >  
> > -	return (i < num_node_memblks) ? node_memblk[i].nid : (num_node_memblks ? -1 : 0);
> > +	return (i < num_node_memblks) ?
> > +		node_memblk[i].nid : (num_node_memblks ? -1 : 0);
> >  }
> 
> Looks like just a whitespace change.

But really far less radical than it deserves ... nested conditional
expressions?  Come on.  How about:

	if (i < num_node_memblks)
		return node_memblk[i].nid;
	if (num_node_memblks)
		return -1;
	return 0;
