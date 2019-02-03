From: Mike Rapoport <rppt@linux.ibm.com>
Date: Sun, 03 Feb 2019 10:04:28 +0000
Subject: Re: [PATCH v2 10/21] memblock: refactor internal allocation functions
Message-Id: <20190203100428.GB8620@rapoport-lnx>
List-Id: <linux-ia64.vger.kernel.org>
References: <1548057848-15136-1-git-send-email-rppt@linux.ibm.com>
 <1548057848-15136-11-git-send-email-rppt@linux.ibm.com>
 <87ftt5nrcn.fsf@concordia.ellerman.id.au>
In-Reply-To: <87ftt5nrcn.fsf@concordia.ellerman.id.au>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Michael Ellerman <mpe@ellerman.id.au>
Cc: Rich Felker <dalias@libc.org>, linux-ia64@vger.kernel.org, devicetree@vger.kernel.org, Catalin Marinas <catalin.marinas@arm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, x86@kernel.org, linux-mips@vger.kernel.org, Max Filippov <jcmvbkbc@gmail.com>, Guo Ren <guoren@kernel.org>, sparclinux@vger.kernel.org, Christoph Hellwig <hch@lst.de>, linux-s390@vger.kernel.org, linux-c6x-dev@linux-c6x.org, Yoshinori Sato <ysato@users.sourceforge.jp>, Richard Weinberger <richard@nod.at>, linux-sh@vger.kernel.org, Russell King <linux@armlinux.org.uk>, kasan-dev@googlegroups.com, Geert Uytterhoeven <geert@linux-m68k.org>, Mark Salter <msalter@redhat.com>, Dennis Zhou <dennis@kernel.org>, Matt Turner <mattst88@gmail.com>, linux-snps-arc@lists.infradead.org, uclinux-h8-devel@lists.sourceforge.jp, Petr Mladek <pmladek@suse.com>, linux-xtensa@linux-xtensa.org, linux-alpha@vger.kernel.org, linux-um@lists.infradead.org, linux-m68k@lists.linux-m68k.org, Rob Herring <robh+dt@kernel.org>, Greentime Hu <green.hu@gmail.com>, xen-devel@lists.xenproject.org, Stafford Horne <shorne@gmail.com>, Guan Xuetao <gxt@pku.edu.cn>, linux-arm-kernel@lists.infradead.org, Michal Simek <monstr@monstr.eu>, Tony Luck <tony.luck@intel.com>, linux-mm@kvack.org, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, linux-usb@vger.kernel.org, linux-kernel@vger.kernel.org, Paul Burton <paul.burton@mips.com>, openrisc@lists.librecores.org, Vineet Gupta <vgupta@synopsys.com>, Andrew Morton <akpm@linux-foundation.org>, linuxppc-dev@lists.ozlabs.org, "David S. Miller" <davem@davemloft.net>

On Sun, Feb 03, 2019 at 08:39:20PM +1100, Michael Ellerman wrote:
> Mike Rapoport <rppt@linux.ibm.com> writes:
> 
> > Currently, memblock has several internal functions with overlapping
> > functionality. They all call memblock_find_in_range_node() to find free
> > memory and then reserve the allocated range and mark it with kmemleak.
> > However, there is difference in the allocation constraints and in fallback
> > strategies.
> >
> > The allocations returning physical address first attempt to find free
> > memory on the specified node within mirrored memory regions, then retry on
> > the same node without the requirement for memory mirroring and finally fall
> > back to all available memory.
> >
> > The allocations returning virtual address start with clamping the allowed
> > range to memblock.current_limit, attempt to allocate from the specified
> > node from regions with mirroring and with user defined minimal address. If
> > such allocation fails, next attempt is done with node restriction lifted.
> > Next, the allocation is retried with minimal address reset to zero and at
> > last without the requirement for mirrored regions.
> >
> > Let's consolidate various fallbacks handling and make them more consistent
> > for physical and virtual variants. Most of the fallback handling is moved
> > to memblock_alloc_range_nid() and it now handles node and mirror fallbacks.
> >
> > The memblock_alloc_internal() uses memblock_alloc_range_nid() to get a
> > physical address of the allocated range and converts it to virtual address.
> >
> > The fallback for allocation below the specified minimal address remains in
> > memblock_alloc_internal() because memblock_alloc_range_nid() is used by CMA
> > with exact requirement for lower bounds.
> 
> This is causing problems on some of my machines.
> 
> I see NODE_DATA allocations falling back to node 0 when they shouldn't,
> or didn't previously.
> 
> eg, before:
> 
> 57990190: (116011251): numa:   NODE_DATA [mem 0xfffe4980-0xfffebfff]
> 58152042: (116373087): numa:   NODE_DATA [mem 0x8fff90980-0x8fff97fff]
> 
> after:
> 
> 16356872061562: (6296877055): numa:   NODE_DATA [mem 0xfffe4980-0xfffebfff]
> 16356872079279: (6296894772): numa:   NODE_DATA [mem 0xfffcd300-0xfffd497f]
> 16356872096376: (6296911869): numa:     NODE_DATA(1) on node 0
> 
> 
> On some of my other systems it does that, and then panics because it
> can't allocate anything at all:
> 
> [    0.000000] numa:   NODE_DATA [mem 0x7ffcaee80-0x7ffcb3fff]
> [    0.000000] numa:   NODE_DATA [mem 0x7ffc99d00-0x7ffc9ee7f]
> [    0.000000] numa:     NODE_DATA(1) on node 0
> [    0.000000] Kernel panic - not syncing: Cannot allocate 20864 bytes for node 16 data
> [    0.000000] CPU: 0 PID: 0 Comm: swapper Not tainted 5.0.0-rc4-gccN-next-20190201-gdc4c899 #1
> [    0.000000] Call Trace:
> [    0.000000] [c0000000011cfca0] [c000000000c11044] dump_stack+0xe8/0x164 (unreliable)
> [    0.000000] [c0000000011cfcf0] [c0000000000fdd6c] panic+0x17c/0x3e0
> [    0.000000] [c0000000011cfd90] [c000000000f61bc8] initmem_init+0x128/0x260
> [    0.000000] [c0000000011cfe60] [c000000000f57940] setup_arch+0x398/0x418
> [    0.000000] [c0000000011cfee0] [c000000000f50a94] start_kernel+0xa0/0x684
> [    0.000000] [c0000000011cff90] [c00000000000af70] start_here_common+0x1c/0x52c
> [    0.000000] Rebooting in 180 seconds..
> 
> 
> So there's something going wrong there, I haven't had time to dig into
> it though (Sunday night here).

I'll try to see if I can reproduce it with qemu.
 
> cheers
> 

-- 
Sincerely yours,
Mike.
