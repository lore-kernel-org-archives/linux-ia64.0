From: Christophe Leroy <christophe.leroy@csgroup.eu>
Date: Mon, 11 Oct 2021 15:25:27 +0000
Subject: [PATCH v1 00/10] Fix LKDTM for PPC64/IA64/PARISC
Message-Id: <cover.1633964380.git.christophe.leroy@csgroup.eu>
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

Patch 6 is not absolutely necessary but it is a good trivial cleanup.

Christophe Leroy (10):
  powerpc: Move 'struct ppc64_opd_entry' back into asm/elf.h
  powerpc: Rename 'funcaddr' to 'addr' in 'struct ppc64_opd_entry'
  ia64: Rename 'ip' to 'addr' in 'struct fdesc'
  asm-generic: Use HAVE_DEREFERENCE_FUNCTION_DESCRIPTOR to define
    associated stubs
  asm-generic: Define 'funct_descr_t' to commonly describe function
    descriptors
  asm-generic: Refactor dereference_[kernel]_function_descriptor()
  lkdtm: Force do_nothing() out of line
  lkdtm: Really write into kernel text in WRITE_KERN
  lkdtm: Fix lkdtm_EXEC_RODATA()
  lkdtm: Fix execute_[user]_location()

 arch/ia64/include/asm/elf.h         |  2 +-
 arch/ia64/include/asm/sections.h    | 24 ++---------
 arch/ia64/kernel/module.c           |  6 +--
 arch/parisc/include/asm/sections.h  | 16 +++----
 arch/parisc/kernel/process.c        | 21 ---------
 arch/powerpc/include/asm/elf.h      |  7 +++
 arch/powerpc/include/asm/sections.h | 30 +++----------
 arch/powerpc/include/uapi/asm/elf.h |  8 ----
 arch/powerpc/kernel/module_64.c     |  6 +--
 drivers/misc/lkdtm/perms.c          | 66 +++++++++++++++++++++++------
 include/asm-generic/sections.h      | 24 ++++++++++-
 11 files changed, 102 insertions(+), 108 deletions(-)

-- 
2.31.1
