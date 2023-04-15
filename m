From: Stanislav Kinsburskii <skinsburskii@linux.microsoft.com>
Date: Sat, 15 Apr 2023 11:17:19 +0000
Subject: [PATCH 0/7] Expect immutable pointer in virt_to_phys/isa_virt_to_bus prototypes
Message-Id: <168155718437.13678.714141668943813263.stgit@skinsburskii.localdomain>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
To: 
Cc: Matt Turner <mattst88@gmail.com>, x86@kernel.org, Stanislav Kinsburskii <stanislav.kinsburskii@gmail.com>, Borislav Petkov <bp@alien8.de>, linux-ia64@vger.kernel.org, Mark Brown <broonie@kernel.org>, Richard Henderson <richard.henderson@linaro.org>, linux-kernel@vger.kernel.org, Brian Cain <bcain@quicinc.com>, linux-mips@vger.kernel.org, Geert Uytterhoeven <geert@linux-m68k.org>, linux-alpha@vger.kernel.org, linux-arch@vger.kernel.org, Michael Ellerman <mpe@ellerman.id.au>, Linus Walleij <linus.walleij@linaro.org>, Jiaxun Yang <jiaxun.yang@flygoat.com>, Bjorn Helgaas <bhelgaas@google.com>, Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave.hansen@linux.intel.com>, Omar Sandoval <osandov@fb.com>, Helge Deller <deller@gmx.de>, linuxppc-dev@lists.ozlabs.org, linux-hexagon@vger.kernel.org, Thomas Bogendoerfer <tsbogend@alpha.franken.de>, Ivan Kokshaysky <ink@jurassic.park.msu.ru>, Ingo Molnar <mingo@redhat.com>, Arnd Bergmann <arnd@arndb.de>, Florian Fainelli <f.fainelli@gmail.com>, Chris Down <chris@chrisdown.name>, Nicholas Piggin <npiggin@gmail.com>, Christophe Leroy <christophe.leroy@csgroup.eu>, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>

This series is aimed to address compilation warnings when a constant pointer
is passed to virt_to_phys and isa_virt_to_bus functions:

  warning: passing argument 1 of ‘virt_to_phys’ discards ‘const’ qualifier from pointer target type
  warning: passing argument 1 of ‘isa_virt_to_bus’ discards ‘const’ qualifier from pointer target type

The change(s) is the same for all architectures, but it's split into a series on
per-arch basis to simplify applying and testing on the maintainers side.

The following series implements...

---

Stanislav Kinsburskii (7):
      x86: asm/io.h: Expect immutable pointer in virt_to_phys/isa_virt_to_bus prototypes
      alpha: asm/io.h: Expect immutable pointer in virt_to_phys/isa_virt_to_bus prototypes
      mips: asm/io.h: Expect immutable pointer in isa_virt_to_bus prototype
      hexagon: asm/io.h: Expect immutable pointer in virt_to_phys prototype
      ia64: asm/io.h: Expect immutable pointer in virt_to_phys prototype
      powerpc: asm/io.h: Expect immutable pointer in virt_to_phys prototype
      asm-generic/io.h: Expect immutable pointer in virt_to_phys


 arch/alpha/include/asm/io.h   |    6 +++---
 arch/hexagon/include/asm/io.h |    2 +-
 arch/ia64/include/asm/io.h    |    2 +-
 arch/mips/include/asm/io.h    |    2 +-
 arch/powerpc/include/asm/io.h |    2 +-
 arch/x86/include/asm/io.h     |    4 ++--
 include/asm-generic/io.h      |    2 +-
 7 files changed, 10 insertions(+), 10 deletions(-)

