From: Catalin Marinas <catalin.marinas@arm.com>
Date: Mon, 11 May 2020 11:00:14 +0000
Subject: Re: [PATCH 02/31] arm64: fix the flush_icache_range arguments in machine_kexec
Message-Id: <20200511110014.GA19176@gaia>
List-Id: <linux-ia64.vger.kernel.org>
References: <20200510075510.987823-1-hch@lst.de>
 <20200510075510.987823-3-hch@lst.de>
 <20200511075115.GA16134@willie-the-truck>
In-Reply-To: <20200511075115.GA16134@willie-the-truck>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Will Deacon <will@kernel.org>
Cc: Christoph Hellwig <hch@lst.de>, james.morse@arm.com, Andrew Morton <akpm@linux-foundation.org>, Arnd Bergmann <arnd@arndb.de>, Roman Zippel <zippel@linux-m68k.org>, Jessica Yu <jeyu@kernel.org>, Michal Simek <monstr@monstr.eu>, x86@kernel.org, linux-alpha@vger.kernel.org, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-c6x-dev@linux-c6x.org, linux-hexagon@vger.kernel.org, linux-ia64@vger.kernel.org, linux-m68k@lists.linux-m68k.org, linux-mips@vger.kernel.org, openrisc@lists.librecores.org, linuxppc-dev@lists.ozlabs.org, linux-riscv@lists.infradead.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, linux-um@lists.infradead.org, linux-xtensa@linux-xtensa.org, linux-fsdevel@vger.kernel.org

On Mon, May 11, 2020 at 08:51:15AM +0100, Will Deacon wrote:
> On Sun, May 10, 2020 at 09:54:41AM +0200, Christoph Hellwig wrote:
> > The second argument is the end "pointer", not the length.
> > 
> > Signed-off-by: Christoph Hellwig <hch@lst.de>
> > ---
> >  arch/arm64/kernel/machine_kexec.c | 1 +
> >  1 file changed, 1 insertion(+)
> > 
> > diff --git a/arch/arm64/kernel/machine_kexec.c b/arch/arm64/kernel/machine_kexec.c
> > index 8e9c924423b4e..a0b144cfaea71 100644
> > --- a/arch/arm64/kernel/machine_kexec.c
> > +++ b/arch/arm64/kernel/machine_kexec.c
> > @@ -177,6 +177,7 @@ void machine_kexec(struct kimage *kimage)
> >  	 * the offline CPUs. Therefore, we must use the __* variant here.
> >  	 */
> >  	__flush_icache_range((uintptr_t)reboot_code_buffer,
> > +			     (uintptr_t)reboot_code_buffer +
> >  			     arm64_relocate_new_kernel_size);
> 
> Urgh, well spotted. It's annoyingly different from __flush_dcache_area().
> 
> But now I'm wondering what this code actually does... the loop condition
> in invalidate_icache_by_line works with 64-bit arithmetic, so we could
> spend a /very/ long time here afaict.

I think it goes through the loop only once. The 'b.lo' saves us here.
OTOH, there is no I-cache maintenance done.

> It's also a bit annoying that we do a bunch of redundant D-cache
> maintenance too. Should we use invalidate_icache_range() here instead?

Since we have the __flush_dcache_area() above it for cleaning to PoC, we
could use invalidate_icache_range() here. We probably didn't have this
function at the time, it was added for KVM (commit 4fee94736603cd6).

> (and why does that thing need to toggle uaccess)?

invalidate_icache_range() doesn't need to, it works on the kernel linear
map.

__flush_icache_range() doesn't need to either, that's a side-effect of
the fall-through implementation.

Anyway, I think Christoph's patch needs to go in with a fixes tag:

Fixes: d28f6df1305a ("arm64/kexec: Add core kexec support")
Cc: <stable@vger.kernel.org> # 4.8.x-

and we'll change these functions/helpers going forward for arm64.

Happy to pick this up via the arm64 for-next/fixes branch.

-- 
Catalin
