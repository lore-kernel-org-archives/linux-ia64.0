From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Wed, 16 Jul 2003 04:30:18 +0000
Subject: Re: Can't build current snapshot
Message-Id: <marc-linux-ia64-105832982702159@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105832832401236@msgid-missing>
In-Reply-To: <marc-linux-ia64-105832832401236@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Wed, 16 Jul 2003 14:05:16 +1000, Peter Chubb <peter@chubb.wattle.id.au> said:

  >> From David's BK tree as of this morning, when building for the
  >> simulator:
  Peter>      ...  LD .tmp_vmlinux1
  Peter> arch/ia64/kernel/built-in.o(.text+0x962): In function
  Peter> `efi_init': arch/ia64/kernel/efi.c:468: relocation truncated
  Peter> to fit: IMM22 per_cpu__ia64_phys_stacked_size_p8
  Peter> arch/ia64/kernel/built-in.o(.text+0xbe2):arch/ia64/kernel/efi.c:482:
  Peter> relocation truncated to fit: IMM22
  Peter> per_cpu__ia64_phys_stacked_size_p8
  Peter> arch/ia64/kernel/built-in.o(.text+0x3302): In function
  Peter> fsys_gettimeofday': : relocation truncated to fit: IMM22
  Peter> per_cpu__cpu_info

  Peter> This is with the current cvs snapshot binutils, gcc 3.2.3
  Peter> 20030221 (Debian prerelease)

  Peter> CONFIG_SMP is *not* set, CONFIG_VIRTUAL_MEM_MAP is *not* set.

You'd get this if the per-cpu area is not linked at -PER_CPU_PAGE_SIZE.
Did you start with a clean tree (make mrproper)?

	--david
