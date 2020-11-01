From: Mike Rapoport <rppt@kernel.org>
Date: Sun, 01 Nov 2020 16:55:34 +0000
Subject: Re: [PATCH 11/13] m68k/mm: make node data and node setup depend on CONFIG_DISCONTIGMEM
Message-Id: <20201101165534.GC14628@kernel.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20201027112955.14157-1-rppt@kernel.org>
 <20201027112955.14157-12-rppt@kernel.org>
 <CAMuHMdU4r4CJ1kBu7gx1jkputjDn2S8Lqkj7RPfa3XUnM1QOFg@mail.gmail.com>
 <20201028111631.GF1428094@kernel.org>
In-Reply-To: <20201028111631.GF1428094@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Geert Uytterhoeven <geert@linux-m68k.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Alexey Dobriyan <adobriyan@gmail.com>, Catalin Marinas <catalin.marinas@arm.com>, Greg Ungerer <gerg@linux-m68k.org>, John Paul Adrian Glaubitz <glaubitz@physik.fu-berlin.de>, Jonathan Corbet <corbet@lwn.net>, Matt Turner <mattst88@gmail.com>, Meelis Roos <mroos@linux.ee>, Michael Schmitz <schmitzmic@gmail.com>, Mike Rapoport <rppt@linux.ibm.com>, Russell King <linux@armlinux.org.uk>, Tony Luck <tony.luck@intel.com>, Vineet Gupta <vgupta@synopsys.com>, Will Deacon <will@kernel.org>, alpha <linux-alpha@vger.kernel.org>, Linux ARM <linux-arm-kernel@lists.infradead.org>, "open list:DOCUMENTATION" <linux-doc@vger.kernel.org>, Linux FS Devel <linux-fsdevel@vger.kernel.org>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-m68k <linux-m68k@lists.linux-m68k.org>, Linux MM <linux-mm@kvack.org>, arcml <linux-snps-arc@lists.infradead.org>

On Wed, Oct 28, 2020 at 01:16:41PM +0200, Mike Rapoport wrote:
> Hi Geert,
> 
> On Wed, Oct 28, 2020 at 10:25:49AM +0100, Geert Uytterhoeven wrote:
> > Hi Mike,
> > 
> > On Tue, Oct 27, 2020 at 12:31 PM Mike Rapoport <rppt@kernel.org> wrote:
> > > From: Mike Rapoport <rppt@linux.ibm.com>
> > >
> > > The pg_data_t node structures and their initialization currently depends on
> > > !CONFIG_SINGLE_MEMORY_CHUNK. Since they are required only for DISCONTIGMEM
> > > make this dependency explicit and replace usage of
> > > CONFIG_SINGLE_MEMORY_CHUNK with CONFIG_DISCONTIGMEM where appropriate.
> > >
> > > The CONFIG_SINGLE_MEMORY_CHUNK was implicitly disabled on the ColdFire MMU
> > > variant, although it always presumed a single memory bank. As there is no
> > > actual need for DISCONTIGMEM in this case, make sure that ColdFire MMU
> > > systems set CONFIG_SINGLE_MEMORY_CHUNK to 'y'.
> > >
> > > Signed-off-by: Mike Rapoport <rppt@linux.ibm.com>
> > 
> > Thanks for your patch!
> > 
> > > ---
> > >  arch/m68k/Kconfig.cpu           | 6 +++---
> > >  arch/m68k/include/asm/page_mm.h | 2 +-
> > >  arch/m68k/mm/init.c             | 4 ++--
> > >  3 files changed, 6 insertions(+), 6 deletions(-)
> > 
> > Is there any specific reason you didn't convert the checks for
> > CONFIG_SINGLE_MEMORY_CHUNK in arch/m68k/kernel/setup_mm.c
> 
> In arch/m68k/kernel/setup_mm.c the CONFIG_SINGLE_MEMORY_CHUNK is needed
> for the case when a system has two banks, the kernel is loaded into the
> second bank and so the first bank cannot be used as normal memory. It
> does not matter what memory model will be used in this case. 
> 
> > and arch/m68k/include/asm/virtconvert.h?
>  
> I remember I had build errors and troubles with include file
> dependencies if I changed it there, but I might be mistaken. I'll
> recheck again.

There indeed was an issue with SINGLE_MEMORY_CHUNK that selected
NEED_MULTIPLE_NODES for some reason.
With that fixed and removed CONFIG_SINGLE_MEMORY_CHUNK in
arch/m68k/include/asm/virtconvert.h I'm going to send v2 soon.

I've kept CONFIG_SINGLE_MEMORY_CHUNK for now for backwards compatibility
with the plan to remove it along with DISCONTIGMEM.

> > Gr{oetje,eeting}s,
> > 
> >                         Geert
> > 
> > -- 
> > Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-m68k.org
> > 
> > In personal conversations with technical people, I call myself a hacker. But
> > when I'm talking to journalists I just say "programmer" or something like that.
> >                                 -- Linus Torvalds
> 
> -- 
> Sincerely yours,
> Mike.

-- 
Sincerely yours,
Mike.
