From: Dean Nelson <dcn@sgi.com>
Date: Wed, 04 May 2005 17:13:44 +0000
Subject: Re: catching up on the backlog
Message-Id: <20050504171344.GA15800@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200505032108.j43L8wc21277@unix-os.sc.intel.com>
In-Reply-To: <200505032108.j43L8wc21277@unix-os.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Tony,

It appears that you've missed the following two patches:

   date    subject
   03/22   [PATCH] move nodepda pointer out of pda
   03/23   [PATCH] convert some sn SAL_CALLs to ia64_sal_oemcall calls

When I apply them to your 'release' tree then everything builds cleanly.
By everything, I'm including the 'SGI Altix cross partition functionality'
patches you just applied. (They're the xp* files listed below.)

Note that to build these I had to set 'CONFIG_IA64_SGI_SN_XP=m' during
the 'make oldconfig'. (I had copied 'arch/ia64/configs/sn2_defconfig' to
.config.)

The system booted and ran just fine on an SGI Altix.

Thanks,
Dean

On Tue, May 03, 2005 at 02:08:58PM -0700, tony.luck@intel.com wrote:
> I've picked through the list of patches in my backlog, and applied
> this bunch to my release tree ... before I ask Linus to pull, it
> would be useful to get some SGI testing (since the majority of the
> changes are SGI related).
> 
> -Tony
> 
>  arch/ia64/Kconfig                   |   19 
>  arch/ia64/hp/common/sba_iommu.c     |   34 
>  arch/ia64/kernel/acpi.c             |   23 
>  arch/ia64/kernel/entry.S            |    2 
>  arch/ia64/kernel/fsys.S             |    4 
>  arch/ia64/kernel/mca_drv.c          |    4 
>  arch/ia64/kernel/mca_drv_asm.S      |   18 
>  arch/ia64/kernel/process.c          |   41 
>  arch/ia64/kernel/signal.c           |    3 
>  arch/ia64/lib/flush.S               |    6 
>  arch/ia64/lib/memcpy_mck.S          |    2 
>  arch/ia64/lib/memset.S              |    2 
>  arch/ia64/sn/kernel/Makefile        |    7 
>  arch/ia64/sn/kernel/io_init.c       |   10 
>  arch/ia64/sn/kernel/mca.c           |   34 
>  arch/ia64/sn/kernel/setup.c         |   31 
>  arch/ia64/sn/kernel/tiocx.c         |   60 
>  arch/ia64/sn/kernel/xp_main.c       |  289 +++
>  arch/ia64/sn/kernel/xp_nofault.S    |   31 
>  arch/ia64/sn/kernel/xpc.h           |  991 +++++++++++
>  arch/ia64/sn/kernel/xpc_channel.c   | 2297 ++++++++++++++++++++++++++
>  arch/ia64/sn/kernel/xpc_main.c      | 1064 ++++++++++++
>  arch/ia64/sn/kernel/xpc_partition.c |  984 +++++++++++
>  arch/ia64/sn/kernel/xpnet.c         |  715 ++++++++
>  arch/ia64/sn/pci/pcibr/pcibr_dma.c  |    2 
>  arch/ia64/sn/pci/tioca_provider.c   |    2 
>  drivers/char/Kconfig                |    2 
>  include/asm-ia64/sn/addrs.h         |    8 
>  include/asm-ia64/sn/arch.h          |   17 
>  include/asm-ia64/sn/fetchop.h       |   85 
>  include/asm-ia64/sn/l1.h            |    3 
>  include/asm-ia64/sn/pda.h           |    1 
>  include/asm-ia64/sn/shub_mmr.h      |   24 
>  include/asm-ia64/sn/shubio.h        | 3108 +++++++++++++++++-------------------
>  include/asm-ia64/sn/sn_cpuid.h      |    7 
>  include/asm-ia64/sn/sn_fru.h        |   44 
>  include/asm-ia64/sn/sndrv.h         |   47 
>  include/asm-ia64/sn/xp.h            |  436 +++++
>  kernel/exit.c                       |    2 
>  mm/page_alloc.c                     |    2 
>  40 files changed, 8525 insertions(+), 1936 deletions(-)
