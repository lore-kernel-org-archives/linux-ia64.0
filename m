From: Christophe Leroy <christophe.leroy@csgroup.eu>
Date: Sun, 17 Oct 2021 12:38:13 +0000
Subject: [PATCH v3 00/12] Fix LKDTM for PPC64/IA64/PARISC
Message-Id: <cover.1634457599.git.christophe.leroy@csgroup.eu>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, Andrew Morton <akpm@linux-foundation.org>, "James E.J. Bottomley" <James.Bottomley@HansenPartnership.com>, Helge Deller <deller@gmx.de>, Arnd Bergmann <arnd@arndb.de>, Kees Cook <keescook@chromium.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: Christophe Leroy <christophe.leroy@csgroup.eu>, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-ia64@vger.kernel.org, linux-parisc@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org

PPC64/IA64/PARISC have function descriptors. LKDTM doesn't work
on those three architectures because LKDTM messes up function
descriptors with functions.

This series does some cleanup in the three architectures and
refactors function descriptors so that it can then easily use it
in a generic way in LKDTM.

Patch 8 is not absolutely necessary but it is a good trivial cleanup.

Changes in v3:
- Addressed received comments
- Swapped some of the powerpc patches to keep func_descr_t renamed as struct func_desc and remove 'struct ppc64_opd_entry'
- Changed HAVE_FUNCTION_DESCRIPTORS macro to a config item CONFIG_HAVE_FUNCTION_DESCRIPTORS
- Dropped patch 11 ("Fix lkdtm_EXEC_RODATA()")

Changes in v2:
- Addressed received comments
- Moved dereference_[kernel]_function_descriptor() out of line
- Added patches to remove func_descr_t and func_desc_t in powerpc
- Using func_desc_t instead of funct_descr_t
- Renamed HAVE_DEREFERENCE_FUNCTION_DESCRIPTOR to HAVE_FUNCTION_DESCRIPTORS
- Added a new lkdtm test to check protection of function descriptors

Christophe Leroy (12):
  powerpc: Move and rename func_descr_t
  powerpc: Use 'struct func_desc' instead of 'struct ppc64_opd_entry'
  powerpc: Remove 'struct ppc64_opd_entry'
  powerpc: Prepare func_desc_t for refactorisation
  ia64: Rename 'ip' to 'addr' in 'struct fdesc'
  asm-generic: Define CONFIG_HAVE_FUNCTION_DESCRIPTORS
  asm-generic: Define 'func_desc_t' to commonly describe function
    descriptors
  asm-generic: Refactor dereference_[kernel]_function_descriptor()
  lkdtm: Force do_nothing() out of line
  lkdtm: Really write into kernel text in WRITE_KERN
  lkdtm: Fix execute_[user]_location()
  lkdtm: Add a test for function descriptors protection

 arch/Kconfig                             |  3 +
 arch/ia64/Kconfig                        |  1 +
 arch/ia64/include/asm/elf.h              |  2 +-
 arch/ia64/include/asm/sections.h         | 24 +-------
 arch/ia64/kernel/module.c                |  6 +-
 arch/parisc/Kconfig                      |  1 +
 arch/parisc/include/asm/sections.h       | 16 ++----
 arch/parisc/kernel/process.c             | 21 -------
 arch/powerpc/Kconfig                     |  1 +
 arch/powerpc/include/asm/code-patching.h |  2 +-
 arch/powerpc/include/asm/elf.h           |  6 ++
 arch/powerpc/include/asm/sections.h      | 29 ++--------
 arch/powerpc/include/asm/types.h         |  6 --
 arch/powerpc/include/uapi/asm/elf.h      |  8 ---
 arch/powerpc/kernel/module_64.c          | 38 +++++--------
 arch/powerpc/kernel/ptrace/ptrace.c      |  6 ++
 arch/powerpc/kernel/signal_64.c          |  8 +--
 drivers/misc/lkdtm/core.c                |  1 +
 drivers/misc/lkdtm/lkdtm.h               |  1 +
 drivers/misc/lkdtm/perms.c               | 71 +++++++++++++++++++-----
 include/asm-generic/sections.h           | 13 ++++-
 include/linux/kallsyms.h                 |  2 +-
 kernel/extable.c                         | 23 +++++++-
 23 files changed, 146 insertions(+), 143 deletions(-)

-- 
2.31.1
