From: Peter Chubb <peterc@gelato.unsw.edu.au>
Date: Tue, 01 Nov 2005 02:11:10 +0000
Subject: RE: Recent SPARSEMEM and DISCONTIG changes break some builds
Message-Id: <17254.52926.642115.549098@wombat.chubb.wattle.id.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <17253.37207.664571.236714@wombat.chubb.wattle.id.au>
In-Reply-To: <17253.37207.664571.236714@wombat.chubb.wattle.id.au>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


Please note I'm still seeing problems with DISCONTIGMEM builds...
I think the simplest would be to make CONFIG_DISCONTIGMEM depend on
CONFIG_NUMA and use SPARSEMEM for the other cases.

(This is with:
# CONFIG_SMP is not set
# CONFIG_PREEMPT is not set
CONFIG_SELECT_MEMORY_MODEL=y
# CONFIG_FLATMEM_MANUAL is not set
CONFIG_DISCONTIGMEM_MANUAL=y
# CONFIG_SPARSEMEM_MANUAL is not set
CONFIG_DISCONTIGMEM=y
CONFIG_FLAT_NODE_MEM_MAP=y
CONFIG_NEED_MULTIPLE_NODES=y
# CONFIG_SPARSEMEM_STATIC is not set
CONFIG_SPLIT_PTLOCK_CPUS=4
CONFIG_ARCH_SELECT_MEMORY_MODEL=y
CONFIG_ARCH_DISCONTIGMEM_ENABLE=y
CONFIG_ARCH_FLATMEM_ENABLE=y
CONFIG_ARCH_SPARSEMEM_ENABLE=y
CONFIG_ARCH_DISCONTIGMEM_DEFAULT=y
# CONFIG_NUMA is not set
CONFIG_VIRTUAL_MEM_MAP=y
CONFIG_HOLES_IN_ZONE=y
CONFIG_HAVE_ARCH_EARLY_PFN_TO_NID=y
)
:
In file included from linux-2.6-import/include/linux/slab.h:16,
                 from linux-2.6-import/include/linux/percpu.h:5,
                 from linux-2.6-import/include/linux/sched.h:35,
                 from linux-2.6-import/arch/ia64/kernel/asm-offsets.c:11:
linux-2.6-import/include/linux/gfp.h: In function 'alloc_pages_node':
linux-2.6-import/include/linux/gfp.h:98: warning: implicit declaration of function 'NODE_DATA'
linux-2.6-import/include/linux/gfp.h:98: error: invalid type argument of '->'


-- 
Dr Peter Chubb  http://www.gelato.unsw.edu.au  peterc AT gelato.unsw.edu.au
The technical we do immediately,  the political takes *forever*
