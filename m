From: Russ Anderson <rja@sgi.com>
Date: Thu, 06 Jan 2005 18:21:55 +0000
Subject: Re: [patch] per cpu MCA/INIT fixes.
Message-Id: <200501061821.j06ILt4c190262@ben.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200501060308.j0638M7s194286@ben.americas.sgi.com>
In-Reply-To: <200501060308.j0638M7s194286@ben.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Jesse Barnes wrote:
> On Wednesday, January 5, 2005 7:08 pm, Russ Anderson wrote:
> > Index: linux/arch/ia64/mm/discontig.c
> > =================================> > --- linux.orig/arch/ia64/mm/discontig.c 2005-01-05 15:26:42.455970944 -0600
> > +++ linux/arch/ia64/mm/discontig.c 2005-01-05 15:33:50.644044221 -0600
> > @@ -348,12 +348,12 @@
> >    mem_data[node].node_data = __va(pernode);
> >    pernode += L1_CACHE_ALIGN(sizeof(struct ia64_node_data));
> >
> > -  mca_data_phys = (void *)pernode;
> > -  pernode += L1_CACHE_ALIGN(sizeof(ia64_mca_cpu_t)) * phys_cpus;
> > -
> >    mem_data[node].pgdat->bdata = bdp;
> >    pernode += L1_CACHE_ALIGN(sizeof(pg_data_t));
> >
> > +  mca_data_phys = (void *)pernode;
> > +  pernode += L1_CACHE_ALIGN(sizeof(ia64_mca_cpu_t)) * phys_cpus;
> 
> The above will probably conflict with Jack's recent change to stagger the 
> per-node structures by one cacheline.  You may have to rediff against one of 
> Tony's test trees.

Yea, I wasn't quite sure what to do about that.  Jack's change had not
been accepted, so I didn't want to make my change dependent on it.
His change is only two lines, so it's easy to change my patch if needed.

FWIW, the lines don't conflict and my patch applies correctly on top of
Jack's change.

patching file arch/ia64/mm/discontig.c
Hunk #1 succeeded at 350 (offset 2 lines).
Hunk #2 succeeded at 370 (offset 2 lines).


-- 
Russ Anderson, OS RAS/Partitioning Project Lead  
SGI - Silicon Graphics Inc          rja@sgi.com
