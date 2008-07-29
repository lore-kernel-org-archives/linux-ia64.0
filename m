From: Heiko Carstens <heiko.carstens@de.ibm.com>
Date: Tue, 29 Jul 2008 09:28:47 +0000
Subject: Re: Is topology_core_siblings for use by drivers?
Message-Id: <20080729092847.GA5324@osiris.boeblingen.de.ibm.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20080729071422.GD28989@parisc-linux.org>
In-Reply-To: <20080729071422.GD28989@parisc-linux.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Matthew Wilcox <matthew@wil.cx>
Cc: linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

On Tue, Jul 29, 2008 at 01:14:22AM -0600, Matthew Wilcox wrote:
> 
> allmodconfig currently dies with:
> 
> ERROR: "cpu_core_map" [drivers/net/sfc/sfc.ko] undefined!
> 
> $ grep -r cpu_core_map include/asm-ia64/
> include/asm-ia64/smp.h:extern cpumask_t cpu_core_map[NR_CPUS];
> include/asm-ia64/topology.h:#define topology_core_siblings(cpu) (cpu_core_map[cpu])
> 
> OK ... it's not exported to modules.  Do other architectures have this
> problem?
> 
> $ grep topology_core_siblings include/asm-*/topology.h
> include/asm-ia64/topology.h:#define topology_core_siblings(cpu) (cpu_core_map[cpu])
> include/asm-powerpc/topology.h:#define topology_core_siblings(cpu) (per_cpu(cpu_core_map, cpu))
> include/asm-s390/topology.h:#define topology_core_siblings(cpu) (cpu_core_map[cpu])
> include/asm-x86/topology.h:#define topology_core_siblings(cpu) (per_cpu(cpu_core_map, cpu))
> 
> s390, I guess.  But they don't have PCI device drivers.

Yes, luckily it doesn't get compiled on s390. Btw. the for_each_online_cpu
loop where this gets used doesn't seem to be save wrt cpu hotplug.
