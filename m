From: Christophe Leroy <christophe.leroy@csgroup.eu>
Date: Tue, 15 Feb 2022 12:40:55 +0000
Subject: [PATCH v4 00/13] Fix LKDTM for PPC64/IA64/PARISC v4
Message-Id: <cover.1644928018.git.christophe.leroy@csgroup.eu>
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

Changes in v4:
- Added patch 1 which Fixes 'sparse' for powerpc64le after wrong report on previous series, refer https://github.com/ruscur/linux-ci/actions/runs/1351427671
- Exported dereference_function_descriptor() to modules
- Addressed other received comments
- Rebased on latest powerpc/next (5a72345e6a78120368fcc841b570331b6c5a50da)

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

Christophe Leroy (13):
  powerpc: Fix 'sparse' checking on PPC64le
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
 arch/powerpc/Makefile                    |  2 +-
 arch/powerpc/include/asm/code-patching.h |  2 +-
 arch/powerpc/include/asm/elf.h           |  6 ++
 arch/powerpc/include/asm/sections.h      | 29 ++--------
 arch/powerpc/include/asm/types.h         |  6 --
 arch/powerpc/include/uapi/asm/elf.h      |  8 ---
 arch/powerpc/kernel/module_64.c          | 42 ++++++--------
 arch/powerpc/kernel/ptrace/ptrace.c      |  6 ++
 arch/powerpc/kernel/signal_64.c          |  8 +--
 drivers/misc/lkdtm/core.c                |  1 +
 drivers/misc/lkdtm/lkdtm.h               |  1 +
 drivers/misc/lkdtm/perms.c               | 71 +++++++++++++++++++-----
 include/asm-generic/sections.h           | 15 ++++-
 include/linux/kallsyms.h                 |  2 +-
 kernel/extable.c                         | 24 +++++++-
 tools/testing/selftests/lkdtm/tests.txt  |  1 +
 25 files changed, 155 insertions(+), 144 deletions(-)

-- 
2.34.1
