From: Russ Anderson <rja@sgi.com>
Date: Wed, 26 Jan 2005 17:13:55 +0000
Subject: Re: [patch] fix per-CPU MCA mess and make UP kernels work again
Message-Id: <200501261713.j0QHDtHB12232866@clink.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <16887.1203.470842.161249@napali.hpl.hp.com>
In-Reply-To: <16887.1203.470842.161249@napali.hpl.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Jesse Barnes wrote:
> 
> On Tuesday, January 25, 2005 6:47 pm, David Mosberger wrote:
> > The patch has been compile- and boot-tested for zx1 UP and SMP.  I
> > think it should be OK for discontig configs, too, but I haven't tested
> > that (and if anybody wanted to build discontig for UP, then
> > discontig.c:per_cpu_init() would have to be updated like the contig.c
> > version.
> 
> Did you see the last patch I posted for UP+generic support?  I *think* it 
> fixes things in discontig.c somewhat correctly, but I've asked Russ to take a 
> look to make sure.

I'm trying David's changes on Altix right now with
the error injection (memory uncorrectable) test.

-- 
Russ Anderson, OS RAS/Partitioning Project Lead  
SGI - Silicon Graphics Inc          rja@sgi.com
