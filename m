From: Isaku Yamahata <yamahata@valinux.co.jp>
Date: Tue, 26 Feb 2008 13:58:51 +0000
Subject: [PATCH 0/8] RFC: ia64/xen TAKE 2: paravirtualization of hand written assembly code
Message-Id: <1204034339752-git-send-email-yamahata@valinux.co.jp>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi. I rewrote the patch according to the comments. I adopted generating
in-place code because it looks the quickest way.

The point Eddie wanted to discuss is how to generate code and its ABI.
i.e. in-place generating v.s. direct jump v.s. indirect function call
Indirect function call doesn't make sense because ivt.S is compiled
multi times. And it is up to pv instances to choose in-place generating
or direct jump. So what we should define is its clobbered registers.
The ABI which this patch adopted is xen biased. Presumably we want to
twist those macros to make more hypervisor neutral. (i.e. add more
clobbered registers) Please comment.


TODO:
- more clean ups
  some macro needs clean up to be aware register usage r8, r9.
- Free xen_ivt ares somehow. No waste kernel space
  From Keith Owens idea.
  Probably after defining ABI because this is just optimization.

Changes from TAKE 1:
Single IVT source code. compile multitimes using assembler macros.

Diffstat:
 arch/ia64/kernel/Makefile                          |   32 +-
 arch/ia64/kernel/entry.S                           |  568 +------------------
 arch/ia64/kernel/inst_native.h                     |  153 +++++
 arch/ia64/kernel/ivt.S                             |  159 +++---
 arch/ia64/kernel/minstate.h                        |    2 +
 arch/ia64/kernel/switch_leave.S                    |  609 ++++++++++++++++++++
 arch/ia64/xen/inst_xen.h                           |  307 ++++++++++
 arch/ia64/{kernel/minstate.h => xen/xenminstate.h} |   95 +---
 include/asm-ia64/privop.h                          |   26 +
 9 files changed, 1245 insertions(+), 706 deletions(-)

