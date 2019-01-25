From: Mike Rapoport <rppt@linux.ibm.com>
Date: Fri, 25 Jan 2019 19:32:52 +0000
Subject: Re: [PATCH v2 06/21] memblock: memblock_phys_alloc_try_nid(): don't panic
Message-Id: <20190125193252.GH31519@rapoport-lnx>
List-Id: <linux-ia64.vger.kernel.org>
References: <1548057848-15136-1-git-send-email-rppt@linux.ibm.com>
 <1548057848-15136-7-git-send-email-rppt@linux.ibm.com>
 <20190125174502.GL25901@arrakis.emea.arm.com>
In-Reply-To: <20190125174502.GL25901@arrakis.emea.arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Catalin Marinas <catalin.marinas@arm.com>
Cc: Rich Felker <dalias@libc.org>, linux-ia64@vger.kernel.org, devicetree@vger.kernel.org, Heiko Carstens <heiko.carstens@de.ibm.com>, x86@kernel.org, linux-mips@vger.kernel.org, Max Filippov <jcmvbkbc@gmail.com>, Guo Ren <guoren@kernel.org>, sparclinux@vger.kernel.org, Christoph Hellwig <hch@lst.de>, linux-s390@vger.kernel.org, linux-c6x-dev@linux-c6x.org, Yoshinori Sato <ysato@users.sourceforge.jp>, Richard Weinberger <richard@nod.at>, linux-sh@vger.kernel.org, Russell King <linux@armlinux.org.uk>, kasan-dev@googlegroups.com, Geert Uytterhoeven <geert@linux-m68k.org>, Mark Salter <msalter@redhat.com>, Dennis Zhou <dennis@kernel.org>, Matt Turner <mattst88@gmail.com>, linux-snps-arc@lists.infradead.org, uclinux-h8-devel@lists.sourceforge.jp, Petr Mladek <pmladek@suse.com>, linux-xtensa@linux-xtensa.org, linux-alpha@vger.kernel.org, linux-um@lists.infradead.org, linux-m68k@lists.linux-m68k.org, Rob Herring <robh+dt@kernel.org>, Greentime Hu <green.hu@gmail.com>, xen-devel@lists.xenproject.org, Stafford Horne <shorne@gmail.com>, Guan Xuetao <gxt@pku.edu.cn>, linux-arm-kernel@lists.infradead.org, Michal Simek <monstr@monstr.eu>, Tony Luck <tony.luck@intel.com>, linux-mm@kvack.org, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, linux-usb@vger.kernel.org, linux-kernel@vger.kernel.org, Paul Burton <paul.burton@mips.com>, Vineet Gupta <vgupta@synopsys.com>, Michael Ellerman <mpe@ellerman.id.au>, Andrew Morton <akpm@linux-foundation.org>, linuxppc-dev@lists.ozlabs.org, "David S. Miller" <davem@davemloft.net>, openrisc@lists.librecores.org

On Fri, Jan 25, 2019 at 05:45:02PM +0000, Catalin Marinas wrote:
> On Mon, Jan 21, 2019 at 10:03:53AM +0200, Mike Rapoport wrote:
> > diff --git a/arch/arm64/mm/numa.c b/arch/arm64/mm/numa.c
> > index ae34e3a..2c61ea4 100644
> > --- a/arch/arm64/mm/numa.c
> > +++ b/arch/arm64/mm/numa.c
> > @@ -237,6 +237,10 @@ static void __init setup_node_data(int nid, u64 start_pfn, u64 end_pfn)
> >  		pr_info("Initmem setup node %d [<memory-less node>]\n", nid);
> >  
> >  	nd_pa = memblock_phys_alloc_try_nid(nd_size, SMP_CACHE_BYTES, nid);
> > +	if (!nd_pa)
> > +		panic("Cannot allocate %zu bytes for node %d data\n",
> > +		      nd_size, nid);
> > +
> >  	nd = __va(nd_pa);
> >  
> >  	/* report and initialize */
> 
> Does it mean that memblock_phys_alloc_try_nid() never returns valid
> physical memory starting at 0?

Yes, it does.
memblock_find_in_range_node() that is used by all allocation methods
skips the first page [1].
 
[1] https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memblock.c#n257

> -- 
> Catalin
> 

-- 
Sincerely yours,
Mike.
