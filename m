From: "Luck, Tony" <tony.luck@intel.com>
Date: Mon, 01 Oct 2012 20:38:49 +0000
Subject: [GIT PULL] ia64 changes for 3.7 merge window
Message-Id: <5069ff59302927eb2f@agluck-desktop.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

The following changes since commit 55d512e245bc7699a8800e23df1a24195dd08217:

  Linux 3.6-rc5 (2012-09-08 16:43:45 -0700)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/aegl/linux.git tags/please-pull-ia64-for-3.7

for you to fetch changes up to 39c9a4ab2b91bff26801c86e423ef07fb705b3c0:

  [IA64] xen: Fix return value check in xencomm_vtop() (2012-09-27 12:30:18 -0700)

----------------------------------------------------------------
Usual mish-mash of ia64 fixes for next merge window

----------------------------------------------------------------
Jianguo Wu (1):
      [IA64] Fix a node distance bug

Tony Luck (1):
      [IA64] Must enable interrupts in do_notify_resume_user before calling tracehook_notify_resume()

Wei Yongjun (2):
      [IA64] kexec: Move the dereference below the NULL test
      [IA64] xen: Fix return value check in xencomm_vtop()

 arch/ia64/include/asm/numa.h     | 2 +-
 arch/ia64/kernel/machine_kexec.c | 3 ++-
 arch/ia64/kernel/process.c       | 4 ++--
 arch/ia64/xen/xencomm.c          | 3 ++-
 4 files changed, 7 insertions(+), 5 deletions(-)
