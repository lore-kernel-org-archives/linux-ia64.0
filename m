From: "Luck, Tony" <tony.luck@intel.com>
Date: Tue, 23 Oct 2012 21:41:55 +0000
Subject: [GIT PULL] Fix ia64 UAPI fallout
Message-Id: <50870f238765a2dd5@agluck-desk.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

The following changes since commit c9623de4fc2f8320fe94316b46171683be3b1d59:

  Merge branch 'v4l_for_linus' of git://git.kernel.org/pub/scm/linux/kernel/git/mchehab/linux-media (2012-10-18 16:10:42 -0700)

are available in the git repository at:


  git://git.kernel.org/pub/scm/linux/kernel/git/aegl/linux.git tags/please-pull-uapi-fix

for you to fetch changes up to 7e3cdf242f6dfa8d66dac8e1a5167f3e3101d213:

  UAPI: Make arch/ia64/include/asm/kvm_para.h generic (2012-10-18 17:27:43 -0700)

----------------------------------------------------------------
Fix from dhowells for UAPI fallout

----------------------------------------------------------------
David Howells (1):
      UAPI: Make arch/ia64/include/asm/kvm_para.h generic

 arch/ia64/include/asm/Kbuild     |    1 +
 arch/ia64/include/asm/kvm_para.h |   34 ----------------------------------
 2 files changed, 1 insertion(+), 34 deletions(-)
 delete mode 100644 arch/ia64/include/asm/kvm_para.h
