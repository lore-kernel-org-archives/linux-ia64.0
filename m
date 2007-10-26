From: Kumar Gala <galak@kernel.crashing.org>
Date: Fri, 26 Oct 2007 09:44:26 +0000
Subject: Re: [PATCH] IA64, PPC, SPARC: minor irq handler cleanups
Message-Id: <CF660BA8-BEC6-4CB7-9627-0135ACD46DD8@kernel.crashing.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <9799624f63e093aa915947aea8fb1b8a5df959a1.1193390973.git.jeff@garzik.org> <d12d72446eb0ff40da5e709b1f658df479b92658.1193390975.git.jeff@garzik.org>
In-Reply-To: <d12d72446eb0ff40da5e709b1f658df479b92658.1193390975.git.jeff@garzik.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Jeff Garzik <jeff@garzik.org>
Cc: LKML <linux-kernel@vger.kernel.org>, akpm@linux-foundation.org, davem@davemloft.net, tony.luck@intel.com, linux-ia64@vger.kernel.org, paulus@samba.org, benh@kernel.crashing.org


On Oct 26, 2007, at 4:40 AM, Jeff Garzik wrote:

> ia64/sn/kernel/huberror.c:
> 	- remove pointless void* cast
> 	- add KERN_xxx prefix
>
> ia64/sn/pci/tioce_provider.c: start functions at column zero
>
> ppc/8xx_io/fec.c: kill prototype, remove extra whitespace
>
> ppc/platforms/85xx/*
> 	'irq' argument in irq handler is used purely as a temporary
> 	variable.  Update the function to reflect this usage, changing
> 	the first arg's name from 'irq' to 'dummy'
>
> ppc/platforms/sbc82xx.c: ditto
>
> sparc/kernel/time.c: mark timer_interrupt() static (from DaveM)
>
> Signed-off-by: Jeff Garzik <jgarzik@redhat.com>
> ---
>  arch/ia64/sn/kernel/huberror.c               |    4 ++--
>  arch/ia64/sn/pci/tioce_provider.c            |    6 ++++--
>  arch/ppc/8xx_io/fec.c                        |    3 +--
>  arch/ppc/platforms/85xx/mpc8560_ads.c        |    4 +++-
>  arch/ppc/platforms/85xx/mpc85xx_cds_common.c |    4 +++-
>  arch/ppc/platforms/85xx/stx_gp3.c            |    4 +++-
>  arch/ppc/platforms/85xx/tqm85xx.c            |    4 +++-
>  arch/ppc/platforms/sbc82xx.c                 |    4 +++-
>  arch/sparc/kernel/time.c                     |    2 +-
>  9 files changed, 23 insertions(+), 12 deletions(-)

I haven't been following this with detail.  Is the intent that this  
would be for 2.6.24 or .25?

- k
