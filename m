From: Russ Anderson <rja@efs.americas.sgi.com>
Date: Fri, 27 May 2005 19:00:06 +0000
Subject: Re: flush_icache_range
Message-Id: <200505271900.j4RJ06kF468382@efs.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <4236D7B5.8050408@bull.net>
In-Reply-To: <4236D7B5.8050408@bull.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Grant Grundler wrote: 
> On Fri, May 27, 2005 at 06:45:19PM +0200, Zoltan Menyhart wrote:
> > Anyway, due to the usage of the #ifdef CONFIG_ITANIUM's
> > and the way how they are used, I think the current kernel
> > does not support mixed Itanium 1 and 2 CPUs.
> 
> I'm not sure how the HW could support given the two
> use a different system bus (Merced vs Mckinley).
> 
> Even if someone made a chipset that could supported it (NumaLink?)
> they might ban such configurations to avoid getting
> dragged to the lowest common denominator in performance
> or have pay obscene amounts to test something few customers
> will actually use.

SGI does not mix Merced & McKinley in the same NUMAlinked system.

-- 
Russ Anderson, OS RAS/Partitioning Project Lead  
SGI - Silicon Graphics Inc          rja@sgi.com
