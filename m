From: Peter Chubb <peter@chubb.wattle.id.au>
Date: Wed, 16 Jul 2003 04:05:16 +0000
Subject: Can't build current snapshot
Message-Id: <marc-linux-ia64-105832832401236@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org



From David's BK tree as of this morning, when building for the simulator:
     ...
  LD      .tmp_vmlinux1
arch/ia64/kernel/built-in.o(.text+0x962): In function `efi_init':
arch/ia64/kernel/efi.c:468: relocation truncated to fit: IMM22 per_cpu__ia64_phys_stacked_size_p8
arch/ia64/kernel/built-in.o(.text+0xbe2):arch/ia64/kernel/efi.c:482: relocation truncated to fit: IMM22 per_cpu__ia64_phys_stacked_size_p8
arch/ia64/kernel/built-in.o(.text+0x3302): In function fsys_gettimeofday': : relocation truncated to fit: IMM22 per_cpu__cpu_info

This is with the current cvs snapshot binutils, 
gcc 3.2.3 20030221 (Debian prerelease)

CONFIG_SMP is *not* set, CONFIG_VIRTUAL_MEM_MAP is *not* set.

--
Dr Peter Chubb  http://www.gelato.unsw.edu.au  peterc AT gelato.unsw.edu.au
You are lost in a maze of BitKeeper repositories,   all slightly different.
