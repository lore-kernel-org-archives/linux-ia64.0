From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Date: Fri, 18 Jan 2019 08:42:30 +0000
Subject: Re: [PATCH 21/21] memblock: drop memblock_alloc_*_nopanic() variants
Message-Id: <20190118084230.GA8855@kroah.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1547646261-32535-1-git-send-email-rppt@linux.ibm.com>
 <1547646261-32535-22-git-send-email-rppt@linux.ibm.com>
In-Reply-To: <1547646261-32535-22-git-send-email-rppt@linux.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Mike Rapoport <rppt@linux.ibm.com>
Cc: Rich Felker <dalias@libc.org>, linux-ia64@vger.kernel.org, devicetree@vger.kernel.org, Catalin Marinas <catalin.marinas@arm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, x86@kernel.org, linux-mips@vger.kernel.org, Max Filippov <jcmvbkbc@gmail.com>, Guo Ren <guoren@kernel.org>, sparclinux@vger.kernel.org, Christoph Hellwig <hch@lst.de>, linux-s390@vger.kernel.org, linux-c6x-dev@linux-c6x.org, Yoshinori Sato <ysato@users.sourceforge.jp>, Richard Weinberger <richard@nod.at>, linux-sh@vger.kernel.org, Russell King <linux@armlinux.org.uk>, kasan-dev@googlegroups.com, Geert Uytterhoeven <geert@linux-m68k.org>, Mark Salter <msalter@redhat.com>, Dennis Zhou <dennis@kernel.org>, Matt Turner <mattst88@gmail.com>, linux-snps-arc@lists.infradead.org, uclinux-h8-devel@lists.sourceforge.jp, Petr Mladek <pmladek@suse.com>, linux-xtensa@linux-xtensa.org, linux-alpha@vger.kernel.org, linux-um@lists.infradead.org, linux-m68k@lists.linux-m68k.org, Rob Herring <robh+dt@kernel.org>, Greentime Hu <green.hu@gmail.com>, xen-devel@lists.xenproject.org, Stafford Horne <shorne@gmail.com>, Guan Xuetao <gxt@pku.edu.cn>, linux-arm-kernel@lists.infradead.org, Michal Simek <monstr@monstr.eu>, Tony Luck <tony.luck@intel.com>, linux-mm@kvack.org, Vineet Gupta <vgupta@synopsys.com>, linux-usb@vger.kernel.org, linux-kernel@vger.kernel.org, Paul Burton <paul.burton@mips.com>, openrisc@lists.librecores.org, Michael Ellerman <mpe@ellerman.id.au>, Andrew Morton <akpm@linux-foundation.org>, linuxppc-dev@lists.ozlabs.org, "David S. Miller" <davem@davemloft.net>

On Wed, Jan 16, 2019 at 03:44:21PM +0200, Mike Rapoport wrote:
> As all the memblock allocation functions return NULL in case of error
> rather than panic(), the duplicates with _nopanic suffix can be removed.
> 
> Signed-off-by: Mike Rapoport <rppt@linux.ibm.com>
> ---
>  arch/arc/kernel/unwind.c       |  3 +--
>  arch/sh/mm/init.c              |  2 +-
>  arch/x86/kernel/setup_percpu.c | 10 +++++-----
>  arch/x86/mm/kasan_init_64.c    | 14 ++++++++------
>  drivers/firmware/memmap.c      |  2 +-
>  drivers/usb/early/xhci-dbc.c   |  2 +-
>  include/linux/memblock.h       | 35 -----------------------------------
>  kernel/dma/swiotlb.c           |  2 +-
>  kernel/printk/printk.c         | 17 +++++++----------
>  mm/memblock.c                  | 35 -----------------------------------
>  mm/page_alloc.c                | 10 +++++-----
>  mm/page_ext.c                  |  2 +-
>  mm/percpu.c                    | 11 ++++-------
>  mm/sparse.c                    |  6 ++----
>  14 files changed, 37 insertions(+), 114 deletions(-)

Acked-by: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
