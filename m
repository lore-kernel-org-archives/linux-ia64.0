From: Dou Liyang <douly.fnst@cn.fujitsu.com>
Date: Fri, 01 Sep 2017 02:56:32 +0000
Subject: [PATCH v2 0/7] Remove the parent_node() for each arch
Message-Id: <1504234599-29533-1-git-send-email-douly.fnst@cn.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: akpm@linux-foundation.org, linux-kernel@vger.kernel.org
Cc: Dou Liyang <douly.fnst@cn.fujitsu.com>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, linux-ia64@vger.kernel.org, Ralf Baechle <ralf@linux-mips.org>, James Hogan <james.hogan@imgtec.com>, linux-mips@linux-mips.org, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Michael Holzheu <holzheu@linux.vnet.ibm.com>, linux-s390@vger.kernel.org, Yoshinori Sato <ysato@users.sourceforge.jp>, Rich Felker <dalias@libc.org>, linux-sh@vger.kernel.org, "David S. Miller" <davem@davemloft.net>, sparclinux@vger.kernel.org, Chris Metcalf <cmetcalf@mellanox.com>, Arnd Bergmann <arnd@arndb.de>, linux-arch@vger.kernel.org

Changelog:

v1 --> v2:
   --Remove the patches which have been add to each arch tree individually.
      [01/11] arm64   ...Has been added to arm64 tree, Queued for 4.14
      [03/11] metag   ...Has been added to the -mm tree
      [05/11] powerpc ...Has been added to the powerpc tree
      [10/11] x86     ...Has been added to the tip sched/core

   --Rebase the remaining patches and repost.

Michael reports the parent_node() will never be invoked since the
Commit a7be6e5a7f8d ("mm: drop useless local parameters of
__register_one_node()") removes the last user of it. 

So we start removing it from the topology.h headers for each arch.

Cc: Tony Luck <tony.luck@intel.com>
Cc: Fenghua Yu <fenghua.yu@intel.com>
Cc: linux-ia64@vger.kernel.org
Cc: Ralf Baechle <ralf@linux-mips.org>
Cc: James Hogan <james.hogan@imgtec.com>
Cc: linux-mips@linux-mips.org
Cc: Martin Schwidefsky <schwidefsky@de.ibm.com>
Cc: Heiko Carstens <heiko.carstens@de.ibm.com>
Cc: Michael Holzheu <holzheu@linux.vnet.ibm.com>
Cc: linux-s390@vger.kernel.org
Cc: Yoshinori Sato <ysato@users.sourceforge.jp>
Cc: Rich Felker <dalias@libc.org>
Cc: linux-sh@vger.kernel.org
Cc: "David S. Miller" <davem@davemloft.net>
Cc: sparclinux@vger.kernel.org
Cc: Chris Metcalf <cmetcalf@mellanox.com>
Cc: Arnd Bergmann <arnd@arndb.de>
Cc: linux-arch@vger.kernel.org
Cc: akpm@linux-foundation.org

Dou Liyang (7):
  ia64: topology: Remove the unused parent_node() macro
  MIPS: numa: Remove the unused parent_node() macro
  s390/topology: Remove the unused parent_node() macro
  sh/numa: Remove the unused parent_node() macro
  sparc64/topology: Remove the unused parent_node() macro
  tile/topology: Remove the unused parent_node() macro
  asm-generic: numa: Remove the unused parent_node() macro

 arch/ia64/include/asm/topology.h                 | 7 -------
 arch/mips/include/asm/mach-ip27/topology.h       | 1 -
 arch/mips/include/asm/mach-loongson64/topology.h | 1 -
 arch/s390/include/asm/topology.h                 | 6 ------
 arch/sh/include/asm/topology.h                   | 1 -
 arch/sparc/include/asm/topology_64.h             | 2 --
 arch/tile/include/asm/topology.h                 | 6 ------
 include/asm-generic/topology.h                   | 3 ---
 8 files changed, 27 deletions(-)

-- 
2.5.5



