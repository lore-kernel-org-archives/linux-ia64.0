From: Robin Holt <holt@sgi.com>
Date: Fri, 06 Feb 2004 17:20:07 +0000
Subject: linux-2.5 tree no longer builds.
Message-Id: <20040206172007.GA19538@lnx-holt>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

It appears that the following:

ChangeSet 1.1532.9.160 2004/02/04 10:54:15 akpm@osdl.org
  [PATCH] Fix ptrace in the vsyscall dso area
  
  From: Roland McGrath <roland@redhat.com>
  
  The #include is the part of this patch that matters, so the #ifdef below
  works.

breaks the linux.bkbits.net/linux-2.5 tree for ia64 with the following:

arch/ia64/ia32/elfcore32.h:20: conflicting types for `elf_gregset_t'
include/asm/elf.h:160: previous declaration of `elf_gregset_t'
arch/ia64/ia32/elfcore32.h:22: conflicting types for `elf_fpregset_t'
include/asm/elf.h:163: previous declaration of `elf_fpregset_t'
arch/ia64/ia32/elfcore32.h:23: conflicting types for `elf_fpxregset_t'
include/asm/elf.h:157: previous declaration of `elf_fpxregset_t'
In file included from arch/ia64/ia32/binfmt_elf32.c:22:
arch/ia64/ia32/elfcore32.h:69:1: warning: "ELF_CORE_COPY_REGS" redefined
In file included from include/linux/elf.h:5,
                 from include/linux/mm.h:15,
                 from arch/ia64/ia32/binfmt_elf32.c:15:
include/asm/elf.h:169:1: warning: this is the location of the previous definition



I commented out the #include in linux/mm.h and everything builds fine.
I haven't booted it yet.

Does anybody have a correct fix?

Thanks,
Robin Holt
