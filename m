From: Greg Edwards <edwardsg@sgi.com>
Date: Thu, 22 Sep 2005 16:38:59 +0000
Subject: Re: [PATCH 1/4] V4 ia64 SPARSEMEM - Kconfig and Makefile
Message-Id: <20050922163859.GJ13174@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20050922161425.GX16066@localhost.localdomain>
In-Reply-To: <20050922161425.GX16066@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, Sep 22, 2005 at 12:14:25PM -0400, Bob Picco wrote:
| 
| The patch modifies the Kconfig file to introduce the new memory model
| options and other related SPARSEMEM changes.  There is also a minor change 
| in the Makefile.

This doesn't seem to be working entirely yet.  If I make sn2_defconfig
and manually switch to SPARSEMEM_MANUAL it does the right thing.

If I make the generic defconfig, and switch it to SPARSEMEM_MANUAL,
VIRTUAL_MEM_MAP is still left on:

[...]
CONFIG_IA64_GENERIC=y
[...]
CONFIG_SELECT_MEMORY_MODEL=y
# CONFIG_FLATMEM_MANUAL is not set
# CONFIG_DISCONTIGMEM_MANUAL is not set
CONFIG_SPARSEMEM_MANUAL=y
CONFIG_DISCONTIGMEM=y
CONFIG_SPARSEMEM=y
CONFIG_NEED_MULTIPLE_NODES=y
CONFIG_HAVE_MEMORY_PRESENT=y
# CONFIG_SPARSEMEM_STATIC is not set
CONFIG_SPARSEMEM_EXTREME=y
CONFIG_ARCH_SELECT_MEMORY_MODEL=y
CONFIG_ARCH_FLATMEM_ENABLE=y
CONFIG_ARCH_DISCONTIGMEM_ENABLE=y
CONFIG_ARCH_DISCONTIGMEM_DEFAULT=y
CONFIG_ARCH_SPARSEMEM_ENABLE=y
CONFIG_NUMA=y
CONFIG_VIRTUAL_MEM_MAP=y
CONFIG_HOLES_IN_ZONE=y
CONFIG_HAVE_ARCH_EARLY_PFN_TO_NID=y
[...]
