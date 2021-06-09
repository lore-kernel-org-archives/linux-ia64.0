From: Mike Rapoport <rppt@kernel.org>
Date: Wed, 09 Jun 2021 06:52:08 +0000
Subject: Re: [PATCH v3 8/9] mm: replace CONFIG_NEED_MULTIPLE_NODES with CONFIG_NUMA
Message-Id: <YMBlGBxaWDPV1ouT@kernel.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20210608091316.3622-1-rppt@kernel.org>
 <20210608091316.3622-9-rppt@kernel.org>
 <20210608172544.d9bf17549565d866fbb18451@linux-foundation.org>
In-Reply-To: <20210608172544.d9bf17549565d866fbb18451@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Arnd Bergmann <arnd@arndb.de>, Geert Uytterhoeven <geert@linux-m68k.org>, Ivan Kokshaysky <ink@jurassic.park.msu.ru>, Jonathan Corbet <corbet@lwn.net>, Matt Turner <mattst88@gmail.com>, Mike Rapoport <rppt@linux.ibm.com>, Richard Henderson <rth@twiddle.net>, Vineet Gupta <vgupta@synopsys.com>, kexec@lists.infradead.org, linux-alpha@vger.kernel.org, linux-arch@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-doc@vger.kernel.org, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, linux-m68k@vger.kernel.org, linux-mips@vger.kernel.org, linux-mm@kvack.org, linux-riscv@lists.infradead.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, linux-snps-arc@lists.infradead.org, linux-xtensa@linux-xtensa.org, linuxppc-dev@lists.ozlabs.org, sparclinux@vger.kernel.org

On Tue, Jun 08, 2021 at 05:25:44PM -0700, Andrew Morton wrote:
> On Tue,  8 Jun 2021 12:13:15 +0300 Mike Rapoport <rppt@kernel.org> wrote:
> 
> > From: Mike Rapoport <rppt@linux.ibm.com>
> > 
> > After removal of DISCINTIGMEM the NEED_MULTIPLE_NODES and NUMA
> > configuration options are equivalent.
> > 
> > Drop CONFIG_NEED_MULTIPLE_NODES and use CONFIG_NUMA instead.
> > 
> > Done with
> > 
> > 	$ sed -i 's/CONFIG_NEED_MULTIPLE_NODES/CONFIG_NUMA/' \
> > 		$(git grep -wl CONFIG_NEED_MULTIPLE_NODES)
> > 	$ sed -i 's/NEED_MULTIPLE_NODES/NUMA/' \
> > 		$(git grep -wl NEED_MULTIPLE_NODES)
> > 
> > with manual tweaks afterwards.
> > 
> > ...
> >
> > --- a/include/linux/mmzone.h
> > +++ b/include/linux/mmzone.h
> > @@ -987,7 +987,7 @@ extern int movable_zone;
> >  #ifdef CONFIG_HIGHMEM
> >  static inline int zone_movable_is_highmem(void)
> >  {
> > -#ifdef CONFIG_NEED_MULTIPLE_NODES
> > +#ifdef CONFIG_NUMA
> >  	return movable_zone = ZONE_HIGHMEM;
> >  #else
> >  	return (ZONE_MOVABLE - 1) = ZONE_HIGHMEM;
> 
> I dropped this hunk - your "mm/mmzone.h: simplify is_highmem_idx()"
> removed zone_movable_is_highmem().  

Ah, right.
Thanks!

-- 
Sincerely yours,
Mike.
