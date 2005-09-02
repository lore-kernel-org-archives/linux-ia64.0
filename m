From: Russ Anderson <rja@efs.americas.sgi.com>
Date: Fri, 02 Sep 2005 15:52:31 +0000
Subject: Re: [PATCH] altix: Add volatile qualifiers in places where it seems necessary
Message-Id: <200509021552.j82FqV3Y2377163@efs.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20050902153612.8521.73623.91869@attica.americas.sgi.com>
In-Reply-To: <20050902153612.8521.73623.91869@attica.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Mark Maule wrote:
> On Fri, Sep 02, 2005 at 04:38:09PM +0100, Christoph Hellwig wrote:
> > On Fri, Sep 02, 2005 at 10:36:12AM -0500, Mark Maule wrote:
> > > Add missing volatile qualifier to hardware MMR pointers in various SN files.
> > > Cosmetic code rearranging in pcibr_reg.c to avoid line-wraps.
> > 
> > Volatile usage is wrong most of the time, and your use is certainly.
> > It seems you're accessing mmio-space or something similar and should
> > use proper acessors for it.
> > 
> 
> Okay.  In these cases, I am indeed accessing mapped reisters.  I don't know
> what you mean by "proper acessors", so a reference would be appreciated.

The BTE code used HUB_L() and HUB_S() for comperable type useage.

In include/asm-ia64/sn/bte.h:

#define BTE_LNSTAT_LOAD(_bte)                                           \
                        HUB_L(_bte->bte_base_addr)


In include/asm-ia64/sn/addrs.h:

#define HUB_L(x)                        (*((volatile typeof(*x) *)x))
#define HUB_S(x,d)                      (*((volatile typeof(*x) *)x) = (d))


-- 
Russ Anderson, OS RAS/Partitioning Project Lead  
SGI - Silicon Graphics Inc          rja@sgi.com
