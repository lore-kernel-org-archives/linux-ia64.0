From: Jesse Barnes <jbarnes@engr.sgi.com>
Date: Mon, 10 Jan 2005 21:29:40 +0000
Subject: Re: [PATCH] implement HAVE_PCI_LEGACY for ia64
Message-Id: <200501101329.40773.jbarnes@engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Tony, the generic part of this patch just got applied to Linus' tree.  Can you 
please include the ia64 part in the tree you have Linus pull from next?

Thanks,
Jesse

On Thursday, December 23, 2004 7:57 am, Jesse Barnes wrote:
> This patch implements the features required for the HAVE_PCI_LEGACY code in
> sysfs.  It allows userspace applications to access legacy I/O ports an
> memory space using files in sysfs on a per-bus basis.  Tested on sn2, but
> it *should* work on other ia64 platforms as well (though zx1 will probably
> need machine vectors to do routing of non-base busses).
>
>  arch/ia64/pci/pci.c             |  114
> +++++++++++++++++++++++++++++++++++++- arch/ia64/sn/pci/pci_dma.c      |  
> 64 ++++++++++++++++++++++
>  include/asm-ia64/machvec.h      |   24 ++++++++
>  include/asm-ia64/machvec_init.h |    3 +
>  include/asm-ia64/machvec_sn2.h  |    6 ++
>  include/asm-ia64/pci.h          |   14 ++++
>  include/asm-ia64/sn/sn_sal.h    |   46 ++++++++++++++++
>  7 files changed, 270 insertions(+), 1 deletion(-)
>
> Signed-off-by: Jesse Barnes <jbarnes@sgi.com>
>
> Thanks,
> Jesse
