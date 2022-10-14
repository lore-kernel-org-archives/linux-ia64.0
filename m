From: Sergey Shtylyov <s.shtylyov@omp.ru>
Date: Fri, 14 Oct 2022 21:22:22 +0000
Subject: [PATCH 00/13] Make user_regset_copyin_ignore() *void*
Message-Id: <20221014212235.10770-1-s.shtylyov@omp.ru>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Oleg Nesterov <oleg@redhat.com>, Russell King <linux@armlinux.org.uk>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will@kernel.org>, Brian Cain <bcain@quicinc.com>, Thomas Bogendoerfer <tsbogend@alpha.franken.de>, Dinh Nguyen <dinguyen@kernel.org>, Jonas Bonn <jonas@southpole.se>, Stefan Kristiansson <stefan.kristiansson@saunalahti.fi>, Stafford Horne <shorne@gmail.com>, "James E.J. Bottomley" <James.Bottomley@HansenPartnership.com>, Helge Deller <deller@gmx.de>, Michael Ellerman <mpe@ellerman.id.au>, Nicholas Piggin <npiggin@gmail.com>, Christophe Leroy <christophe.leroy@csgroup.eu>, Yoshinori Sato <ysato@users.sourceforge.jp>, Rich Felker <dalias@libc.org>, "David S. Miller" <davem@davemloft.net>, linux-arm-kernel@lists.infradead.org, linux-hexagon@vger.kernel.org, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mips@vger.kernel.org, linux-parisc@vger.kernel.org, linux-sh@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, openrisc@lists.librecores.org, sparclinux@vger.kernel.org
Cc: Andrew Morton <akpm@linux-foundation.org>, lvc-patches@linuxtesting.org, lvc-project@linuxtesting.org

Here are 13 patches against the 'next-20221014' tag of the 'linux-next.git'
repo.  I'm not sure how this cross-arch series should be merged -- perhaps
thru Andrew Morton's tree?

user_regset_copyin_ignore() apparently cannot fail and so always returns 0.
Let's first remove the result checks in several architectures that call this
function and then make user_regset_copyin_ignore() return *void* instead of
*int*...

Sergey Shtylyov (13):
  arc: ptrace: user_regset_copyin_ignore() always returns 0
  arm: ptrace: user_regset_copyin_ignore() always returns 0
  arm64: ptrace: user_regset_copyin_ignore() always returns 0
  hexagon: ptrace: user_regset_copyin_ignore() always returns 0
  ia64: ptrace: user_regset_copyin_ignore() always returns 0
  mips: ptrace: user_regset_copyin_ignore() always returns 0
  nios2: ptrace: user_regset_copyin_ignore() always returns 0
  openrisc: ptrace: user_regset_copyin_ignore() always returns 0
  parisc: ptrace: user_regset_copyin_ignore() always returns 0
  powerpc: ptrace: user_regset_copyin_ignore() always returns 0
  sh: ptrace: user_regset_copyin_ignore() always returns 0
  sparc: ptrace: user_regset_copyin_ignore() always returns 0
  regset: make user_regset_copyin_ignore() *void*

 arch/arc/kernel/ptrace.c                 |  2 +-
 arch/arm/kernel/ptrace.c                 |  8 +++-----
 arch/arm64/kernel/ptrace.c               | 16 ++++------------
 arch/hexagon/kernel/ptrace.c             |  7 +++----
 arch/ia64/kernel/ptrace.c                | 20 +++++++++-----------
 arch/mips/kernel/ptrace.c                |  9 +++++----
 arch/nios2/kernel/ptrace.c               |  6 +++---
 arch/openrisc/kernel/ptrace.c            |  8 +++-----
 arch/parisc/kernel/ptrace.c              | 15 +++++++++------
 arch/powerpc/kernel/ptrace/ptrace-tm.c   | 10 +++++-----
 arch/powerpc/kernel/ptrace/ptrace-view.c | 10 +++++-----
 arch/sh/kernel/ptrace_32.c               |  8 ++++----
 arch/sparc/kernel/ptrace_32.c            |  9 +++++----
 arch/sparc/kernel/ptrace_64.c            | 23 +++++++++++------------
 include/linux/regset.h                   | 15 +++++++--------
 15 files changed, 77 insertions(+), 89 deletions(-)

-- 
2.26.3
