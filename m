From: David Hildenbrand <david@redhat.com>
Date: Mon, 27 Sep 2021 15:05:14 +0000
Subject: [PATCH v1 0/4] mm/memory_hotplug: full support for
Message-Id: <20210927150518.8607-1-david@redhat.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org
Cc: David Hildenbrand <david@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Mike Rapoport <rppt@kernel.org>, Michal Hocko <mhocko@suse.com>, Oscar Salvador <osalvador@suse.de>, Jianyong Wu <Jianyong.Wu@arm.com>, "Aneesh Kumar K . V" <aneesh.kumar@linux.ibm.com>, Vineet Gupta <vgupta@kernel.org>, Geert Uytterhoeven <geert@linux-m68k.org>, Huacai Chen <chenhuacai@kernel.org>, Jiaxun Yang <jiaxun.yang@flygoat.com>, Thomas Bogendoerfer <tsbogend@alpha.franken.de>, Heiko Carstens <hca@linux.ibm.com>, Vasily Gorbik <gor@linux.ibm.com>, Christian Borntraeger <borntraeger@de.ibm.com>, Eric Biederman <ebiederm@xmission.com>, Arnd Bergmann <arnd@arndb.de>, linux-snps-arc@lists.infradead.org, linux-ia64@vger.kernel.org, linux-m68k@lists.linux-m68k.org, linux-mips@vger.kernel.org, linux-s390@vger.kernel.org, linux-mm@kvack.org, kexec@lists.infradead.org

Architectures that require CONFIG_ARCH_KEEP_MEMBLOCK=y, such as arm64,
don't cleanly support add_memory_driver_managed() yet. Most prominently,
kexec_file can still end up placing images on such driver-managed memory,
resulting in undesired behavior.

Teaching kexec to not place images on driver-managed memory is especially
relevant for virtio-mem. Details can be found in commit 7b7b27214bba
("mm/memory_hotplug: introduce add_memory_driver_managed()").

Extend memblock with a new flag and set it from memory hotplug code
when applicable. This is required to fully support virtio-mem on
arm64, making also kexec_file behave like on x86-64.

Alternative A: Extend kexec_walk_memblock() to consult the kernel resource
tree whether IORESOURCE_SYSRAM_DRIVER_MANAGED is set. This feels wrong,
because the goal was to rely on memblock and not the resource tree.

Alternative B: Reuse MEMBLOCK_HOTPLUG. MEMBLOCK_HOTPLUG serves a different
purpose, though.

Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Mike Rapoport <rppt@kernel.org>
Cc: Michal Hocko <mhocko@suse.com>
Cc: Oscar Salvador <osalvador@suse.de>
Cc: Jianyong Wu <Jianyong.Wu@arm.com>
Cc: Aneesh Kumar K.V <aneesh.kumar@linux.ibm.com>
Cc: Vineet Gupta <vgupta@kernel.org>
Cc: Geert Uytterhoeven <geert@linux-m68k.org>
Cc: Huacai Chen <chenhuacai@kernel.org>
Cc: Jiaxun Yang <jiaxun.yang@flygoat.com>
Cc: Thomas Bogendoerfer <tsbogend@alpha.franken.de>
Cc: Heiko Carstens <hca@linux.ibm.com>
Cc: Vasily Gorbik <gor@linux.ibm.com>
Cc: Christian Borntraeger <borntraeger@de.ibm.com>
Cc: Eric Biederman <ebiederm@xmission.com>
Cc: Arnd Bergmann <arnd@arndb.de>
Cc: linux-snps-arc@lists.infradead.org
Cc: linux-ia64@vger.kernel.org
Cc: linux-m68k@lists.linux-m68k.org
Cc: linux-mips@vger.kernel.org
Cc: linux-s390@vger.kernel.org
Cc: linux-mm@kvack.org
Cc: kexec@lists.infradead.org

David Hildenbrand (4):
  mm/memory_hotplug: handle memblock_add_node() failures in
    add_memory_resource()
  memblock: allow to specify flags with memblock_add_node()
  memblock: add MEMBLOCK_DRIVER_MANAGED to mimic
    IORESOURCE_SYSRAM_DRIVER_MANAGED
  mm/memory_hotplug: indicate MEMBLOCK_DRIVER_MANAGED with
    IORESOURCE_SYSRAM_DRIVER_MANAGED

 arch/arc/mm/init.c               |  4 ++--
 arch/ia64/mm/contig.c            |  2 +-
 arch/ia64/mm/init.c              |  2 +-
 arch/m68k/mm/mcfmmu.c            |  3 ++-
 arch/m68k/mm/motorola.c          |  6 ++++--
 arch/mips/loongson64/init.c      |  4 +++-
 arch/mips/sgi-ip27/ip27-memory.c |  3 ++-
 arch/s390/kernel/setup.c         |  3 ++-
 include/linux/memblock.h         | 19 ++++++++++++++++---
 include/linux/mm.h               |  2 +-
 kernel/kexec_file.c              |  5 +++++
 mm/memblock.c                    | 13 +++++++++----
 mm/memory_hotplug.c              | 11 +++++++++--
 13 files changed, 57 insertions(+), 20 deletions(-)


base-commit: 5816b3e6577eaa676ceb00a848f0fd65fe2adc29
-- 
2.31.1
