From: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Date: Sat, 16 Sep 2017 03:53:42 +0000
Subject: [PATCH 0/5] [RFC] printk/ia64/ppc64/parisc64: let's deprecate %pF/%pf printk specifiers
Message-Id: <20170916035347.19705-1-sergey.senozhatsky@gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, "James E . J . Bottomley" <jejb@parisc-linux.org>, Helge Deller <deller@gmx.de>
Cc: Petr Mladek <pmladek@suse.com>, Steven Rostedt <rostedt@goodmis.org>, Andrew Morton <akpm@linux-foundation.org>, Jessica Yu <jeyu@kernel.org>, Alexei Starovoitov <ast@kernel.org>, linux-ia64@vger.kernel.org, linux-parisc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>

	Hello

	RFC

	On some arches C function pointers are indirect and point to
a function descriptor, which contains the actual pointer to the code.
This mostly doesn't matter, except for cases when people want to print
out function pointers in symbolic format, because the usual '%pS/%ps'
does not work on those arches as expected. That's the reason why we
have '%pF/%pf', but since it's here because of a subtle ABI detail
specific to some arches (ppc64/ia64/parisc64) it's easy to misuse
'%pF/%pf' and '%pS/%ps' (see [1], for example).
	
	This patch set attempts to move ia64/ppc64/parisc64 C function
pointer ABI details out of printk() to arch code. Function dereference
code now checks if a pointer belongs to a .opd ELF section and dereferences
that pointer only if it does. The kernel and modules have their own .opd
sections that's why I use two different ARCH functions: for kernel and
for module pointer dereference.

	I planned to remove dereference_function_descriptor() entirely,
but then I discovered a bunch other uses cases (kgdbts, init/main.c,
extable, etc.), so I decided to keep dereference_function_descriptor()
around because the main point of this patch set is to deprecate %pF/%pf.
But at the same time, I think I can go further and handle both kernel
and module descriptor dereference in dereference_function_descriptor().
We need a module pointer for module .opd check, so that will come at an
extra cost of module lookup (may be there will some other issues along
the way, haven't checked it).

Right now we've got:

- dereference_function_descriptor(addr)
	a generic (old) function. it simply attempts to dereference
	whatever pointer we give it.

- dereference_kernel_function_descriptor(addr)
	dereferences a kernel pointer if it's within the kernel's .opd
	section.

- dereference_module_function_descriptor(module, addr)
	dereference a module pointer if it's within the module's .opd
	section.


*** A BIG NOTE ***
	I don't own ia64/ppc64/parisc64 hardware, so the patches are not
	tested. Sorry about that!


Another note:
	I need to check what is BPF symbol lookup and do we need to
	do any dereference there.


[1] https://marc.info/?l=linux-kernel&m0472969730573

Sergey Senozhatsky (5):
  sections: split dereference_function_descriptor()
  ia64: Add .opd based function descriptor dereference
  powerpc64: Add .opd based function descriptor dereference
  parisc64: Add .opd based function descriptor dereference
  symbol lookup: use new kernel and module dereference functions

 Documentation/printk-formats.txt          | 15 +++++----------
 arch/ia64/include/asm/sections.h          | 14 +++++++++++++-
 arch/ia64/kernel/module.c                 | 13 +++++++++++++
 arch/ia64/kernel/vmlinux.lds.S            |  2 ++
 arch/parisc/boot/compressed/vmlinux.lds.S |  2 ++
 arch/parisc/include/asm/sections.h        |  3 +++
 arch/parisc/kernel/module.c               | 14 ++++++++++++++
 arch/parisc/kernel/process.c              | 10 ++++++++++
 arch/parisc/kernel/vmlinux.lds.S          |  2 ++
 arch/powerpc/include/asm/module.h         |  3 +++
 arch/powerpc/include/asm/sections.h       | 13 +++++++++++++
 arch/powerpc/kernel/module_64.c           | 16 ++++++++++++++++
 arch/powerpc/kernel/vmlinux.lds.S         |  2 ++
 include/asm-generic/sections.h            |  4 ++--
 include/linux/moduleloader.h              |  4 ++++
 kernel/kallsyms.c                         |  1 +
 kernel/module.c                           |  7 +++++++
 lib/vsprintf.c                            |  5 +----
 18 files changed, 113 insertions(+), 17 deletions(-)

-- 
2.14.1

