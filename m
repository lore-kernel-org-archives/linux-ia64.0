From: Jack Steiner <steiner@sgi.com>
Date: Fri, 04 Feb 2005 02:09:57 +0000
Subject: Re: [patch] fix per-CPU MCA mess and make UP kernels work again
Message-Id: <20050204020956.GA924@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <16887.1203.470842.161249@napali.hpl.hp.com>
In-Reply-To: <16887.1203.470842.161249@napali.hpl.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, Feb 03, 2005 at 05:48:26PM -0600, Russ Anderson wrote:
> Tony Luck wrote:
> > 
> > Also I noticed that ia64_sal_to_os_handoff_state
> > hasn't been replicated ... won't we need that too?
> 
> According to the SAL Spec, MCAs are supposed to be handled
> one at a time.  

It has been a long time since I looked, but I thought the
spec allowed either implemention, ie. serialize OR all-at-once.

Maybe I'm remembering the error handling guide but I know
I have seen this somewhere.....


> 
> I would like that to change, so that multiple independent
> MCAs could be handled in parallel, but that would require
> a number of Spec changes (ie the way rendezvous works).
> 
> We should go down that path...
> 
> -- 
> Russ Anderson, OS RAS/Partitioning Project Lead  
> SGI - Silicon Graphics Inc          rja@sgi.com
> -
> To unsubscribe from this list: send the line "unsubscribe linux-ia64" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

-- 
Thanks

Jack Steiner (steiner@sgi.com)          651-683-5302
Principal Engineer                      SGI - Silicon Graphics, Inc.


