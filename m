From: jbarnes@sgi.com (Jesse Barnes)
Date: Fri, 13 Feb 2004 21:51:05 +0000
Subject: Re: GENERIC build failure
Message-Id: <20040213215105.GA20535@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200402132133.i1DLXaYS026393@napali.hpl.hp.com>
In-Reply-To: <200402132133.i1DLXaYS026393@napali.hpl.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

This is fixed in Andrew's tree.  I'm not sure why Len hasn't pushed it
to Linus yet though.

The fix is a simple change of NR_MEMBLKS to NR_NODE_MEMBLKS.

Jesse

On Fri, Feb 13, 2004 at 01:33:36PM -0800, David Mosberger wrote:
> According to this page:
> 
>   http://www.gelato.unsw.edu.au/kerncomp/
> 
> Generic kernel builds are still failing, due to some NUMA cruft.
> I thought this was supposed to be fixed already.  Can someone
> who cares about NUMA investigate?
> 
> 	-d-avid
> -
> To unsubscribe from this list: send the line "unsubscribe linux-ia64" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
