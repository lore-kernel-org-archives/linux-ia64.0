From: Paul Gortmaker <paul.gortmaker@windriver.com>
Date: Sun, 22 Jan 2017 16:32:24 +0000
Subject: [PATCH v3 00/20] Finalize separation of extable.h from module.h
Message-Id: <20170122163244.11740-1-paul.gortmaker@windriver.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org
Cc: Rich Felker <dalias@libc.org>, linux-ia64@vger.kernel.org, linux-sh@vger.kernel.org, David Howells <dhowells@redhat.com>, Max Filippov <jcmvbkbc@gmail.com>, sparclinux@vger.kernel.org, Guan Xuetao <gxt@mprc.pku.edu.cn>, Lennox Wu <lennox.wu@gmail.com>, Jonas Bonn <jonas@southpole.se>, Chen Liqin <liqin.linux@gmail.com>, linux-am33-list@redhat.com, Yoshinori Sato <ysato@users.sourceforge.jp>, linux-hexagon@vger.kernel.org, Russell King <linux@armlinux.org.uk>, Matt Turner <mattst88@gmail.com>, linux-snps-arc@lists.infradead.org, Fenghua Yu <fenghua.yu@intel.com>, James Hogan <james.hogan@imgtec.com>, linux-xtensa@linux-xtensa.org, Rusty Russell <rusty@rustcorp.com.au>, Stefan Kristiansson <stefan.kristiansson@saunalahti.fi>, openrisc@lists.librecores.org, Ivan Kokshaysky <ink@jurassic.park.msu.ru>, Al Viro <viro@zeniv.linux.org.uk>, nios2-dev@lists.rocketboards.org, Staff

If you already read the v2 00/NN, then you can skip this v3; the only
change is to add new arch specific patches that extended build coverage
and more intelligent regex patterns lead to.

Updated copy of the original v2 00/NN text follows:

Some of the arch specific changes have already been picked up by the
arch maintainers in v1, so I'm assuming the other folks just figured I'd
ask Linus to pull the remainder.  Which is the current plan ; soak this
in linux-next on 4.10-rcN and request a pull in the next merge window.

So please shout if you are an arch maintainer and see something here you
have questions or comments on.  Otherwise, you don't have to do anything.

Once all the old users who expected extable content via module.h are
gone, then and only then can we remove the back compat line as done in
the final patch in this series.

I've been build testing this locally on a regular basis in with my other
pending work, on a bunch of different architectures, so hopefully we
don't see anything go pear shaped when it goes into sfr's linux-next.

The only real change in the v1 ---> v2 aside from dropping merged
content was the restructuring in the ia64 based on comments from Al
Viro to improve some header separation at the same time.  I'd resent
just those two for follow up comments and nobody seemed to have further 
suggestions.  Note that I'm not able to run test ia64; just compile.

There was also a minor context refresh required due to the recent
treewide asm/uaccess --> linux/uaccess change, which gave me the
motivation to get this out of my queue and finalized.

RFC/V1: https://lkml.kernel.org/r/CA+55aFyDw_jK609LcjpWvVMTzCWuH6nLUXiZDeYC2tpSaZqhXA@mail.gmail.com
V2: https://lkml.kernel.org/r/20170109204010.5047-1-paul.gortmaker@windriver.com
ia64: https://lkml.kernel.org/r/20160920022924.9537-1-paul.gortmaker@windriver.com

---

Cc: Al Viro <viro@zeniv.linux.org.uk>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Chen Liqin <liqin.linux@gmail.com>
Cc: Chris Zankel <chris@zankel.net>
Cc: David Howells <dhowells@redhat.com>
Cc: "David S. Miller" <davem@davemloft.net>
Cc: Fenghua Yu <fenghua.yu@intel.com>
Cc: Guan Xuetao <gxt@mprc.pku.edu.cn>
Cc: Ivan Kokshaysky <ink@jurassic.park.msu.ru>
Cc: James Hogan <james.hogan@imgtec.com>
Cc: Jonas Bonn <jonas@southpole.se>
Cc: Lennox Wu <lennox.wu@gmail.com>
Cc: Ley Foon Tan <lftan@altera.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Matt Turner <mattst88@gmail.com>
Cc: Max Filippov <jcmvbkbc@gmail.com>
Cc: Michal Simek <monstr@monstr.eu>
Cc: Richard Henderson <rth@twiddle.net>
Cc: Richard Kuo <rkuo@codeaurora.org>
Cc: Rich Felker <dalias@libc.org>
Cc: Russell King <linux@armlinux.org.uk>
Cc: Rusty Russell <rusty@rustcorp.com.au>
Cc: Stafford Horne <shorne@gmail.com>
Cc: Stefan Kristiansson <stefan.kristiansson@saunalahti.fi>
Cc: Sudip Mukherjee <sudipm.mukherjee@gmail.com>
Cc: Tony Luck <tony.luck@intel.com>
Cc: Vineet Gupta <vgupta@synopsys.com>
Cc: Yoshinori Sato <ysato@users.sourceforge.jp>
Cc: linux-alpha@vger.kernel.org
Cc: linux-am33-list@redhat.com
Cc: linux-arm-kernel@lists.infradead.org
Cc: linux-hexagon@vger.kernel.org
Cc: linux-ia64@vger.kernel.org
Cc: linux-sh@vger.kernel.org
Cc: linux-snps-arc@lists.infradead.org
Cc: linux-xtensa@linux-xtensa.org
Cc: nios2-dev@lists.rocketboards.org
Cc: openrisc@lists.librecores.org
Cc: sparclinux@vger.kernel.org

Paul Gortmaker (20):
  ia64: move ia64_done_with_exception out of asm/uaccess.h
  ia64: ensure exception table search users include extable.h
  m32r: migrate exception table users off module.h and onto extable.h
  arm: migrate exception table users off module.h and onto extable.h
  alpha: migrate exception table users off module.h and onto extable.h
  mn10300: migrate exception table users off module.h and onto extable.h
  xtensa: migrate exception table users off module.h and onto extable.h
  sh: migrate exception table users off module.h and onto extable.h
  frv: migrate exception table users off module.h and onto extable.h
  openrisc: migrate exception table users off module.h and onto extable.h
  sparc: migrate exception table users onto extable.h
  nios2: migrate exception table users off module.h and onto extable.h
  arc: migrate exception table users off module.h and onto extable.h
  metag: migrate exception table users off module.h and onto extable.h
  score: migrate exception table users off module.h and onto extable.h
  unicore32: migrate exception table users off module.h and onto extable.h
  microblaze: migrate exception table users off module.h and onto extable.h
  hexagon: migrate exception table users off module.h and onto extable.h
  core: migrate exception table users off module.h and onto extable.h
  module.h: remove extable.h include now users have migrated

 arch/alpha/kernel/traps.c         |  2 +-
 arch/alpha/mm/fault.c             |  2 +-
 arch/arc/mm/extable.c             |  3 ++-
 arch/arm/mm/extable.c             |  2 +-
 arch/arm/mm/fault.c               |  2 +-
 arch/frv/mm/extable.c             |  2 +-
 arch/hexagon/mm/vm_fault.c        |  2 +-
 arch/ia64/include/asm/exception.h | 35 +++++++++++++++++++++++++++++++++++
 arch/ia64/include/asm/uaccess.h   | 15 ---------------
 arch/ia64/kernel/kprobes.c        |  4 ++--
 arch/ia64/kernel/traps.c          |  6 ++++--
 arch/ia64/kernel/unaligned.c      |  4 +++-
 arch/ia64/mm/fault.c              |  2 ++
 arch/m32r/mm/extable.c            |  2 +-
 arch/m32r/mm/fault.c              |  2 +-
 arch/metag/mm/extable.c           |  3 +--
 arch/microblaze/mm/fault.c        |  2 +-
 arch/mn10300/mm/extable.c         |  2 +-
 arch/mn10300/mm/misalignment.c    |  2 +-
 arch/nios2/mm/extable.c           |  2 +-
 arch/nios2/mm/fault.c             |  2 +-
 arch/openrisc/mm/fault.c          |  2 +-
 arch/score/mm/extable.c           |  2 +-
 arch/score/mm/fault.c             |  2 +-
 arch/sh/include/asm/uaccess.h     |  1 -
 arch/sh/kernel/kprobes.c          |  2 +-
 arch/sh/kernel/traps.c            |  3 ++-
 arch/sh/mm/extable_32.c           |  2 +-
 arch/sh/mm/extable_64.c           |  2 +-
 arch/sparc/mm/extable.c           |  1 +
 arch/unicore32/mm/extable.c       |  2 +-
 arch/unicore32/mm/fault.c         |  2 +-
 arch/xtensa/mm/fault.c            |  2 +-
 include/linux/module.h            |  1 -
 init/main.c                       |  1 +
 kernel/extable.c                  |  1 +
 kernel/module.c                   |  1 +
 37 files changed, 77 insertions(+), 48 deletions(-)
 create mode 100644 arch/ia64/include/asm/exception.h

-- 
2.11.0

