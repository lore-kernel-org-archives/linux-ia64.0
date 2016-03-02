From: Will Deacon <will.deacon@arm.com>
Date: Wed, 02 Mar 2016 02:17:10 +0000
Subject: Re: [PATCH 1/2] topology, cleanup: Avoid redefinition of cpumask_of_pcibus in asm header files.
Message-Id: <20160302021710.GJ14022@arm.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1456358528-24213-1-git-send-email-ddaney.cavm@gmail.com>
 <1456358528-24213-2-git-send-email-ddaney.cavm@gmail.com>
In-Reply-To: <1456358528-24213-2-git-send-email-ddaney.cavm@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: David Daney <ddaney.cavm@gmail.com>
Cc: linux-arm-kernel@lists.infradead.org, Mark Rutland <mark.rutland@arm.com>, Catalin Marinas <catalin.marinas@arm.com>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, James Hogan <james.hogan@imgtec.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Yoshinori Sato <ysato@users.sourceforge.jp>, Rich Felker <dalias@libc.org>, "David S. Miller" <davem@davemloft.net>, Chris Metcalf <cmetcalf@ezchip.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org, Arnd Bergmann <arnd@arndb.de>, linux-ia64@vger.kernel.org, linux-metag@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, linux-sh@vger.ker

On Wed, Feb 24, 2016 at 04:02:07PM -0800, David Daney wrote:
> From: Ganapatrao Kulkarni <gkulkarni@caviumnetworks.com>
> 
> At present cpumask_of_pcibus is defined for !CONFIG_NUMA and moving out
> to common will allow to use for numa too. This also avoids
> redefinition of this macro in respective architecture header files.
> 
> Reviewed-by: Robert Richter <rrichter@cavium.com>
> Signed-off-by: Ganapatrao Kulkarni <gkulkarni@caviumnetworks.com>
> Signed-off-by: David Daney <david.daney@cavium.com>
> ---
>  arch/arm64/include/asm/topology.h   | 3 ---
>  arch/ia64/include/asm/topology.h    | 4 ----
>  arch/metag/include/asm/topology.h   | 3 ---
>  arch/powerpc/include/asm/topology.h | 4 ----
>  arch/s390/include/asm/pci.h         | 2 +-
>  arch/s390/include/asm/topology.h    | 1 +
>  arch/sh/include/asm/topology.h      | 3 ---
>  arch/tile/include/asm/pci.h         | 2 --
>  arch/tile/include/asm/topology.h    | 3 +++
>  arch/x86/include/asm/pci.h          | 2 +-
>  arch/x86/include/asm/topology.h     | 1 +
>  include/asm-generic/topology.h      | 4 ++--
>  12 files changed, 9 insertions(+), 23 deletions(-)
> 
> diff --git a/arch/arm64/include/asm/topology.h b/arch/arm64/include/asm/topology.h
> index 8b57339..6e1f62c 100644
> --- a/arch/arm64/include/asm/topology.h
> +++ b/arch/arm64/include/asm/topology.h
> @@ -26,9 +26,6 @@ const struct cpumask *cpu_coregroup_mask(int cpu);
>  
>  struct pci_bus;
>  int pcibus_to_node(struct pci_bus *bus);
> -#define cpumask_of_pcibus(bus)	(pcibus_to_node(bus) = -1 ?		\
> -				 cpu_all_mask :				\
> -				 cpumask_of_node(pcibus_to_node(bus)))
>  
>  #endif /* CONFIG_NUMA */

Looks like a sensible clean up to me (on top of the arm64 NUMA patches):

Acked-by: Will Deacon <will.deacon@arm.com>

Will
