From: "Luck, Tony" <tony.luck@intel.com>
Date: Thu, 02 Jul 2015 21:36:55 +0000
Subject: [GIT PULL] ia64: fix some boot time noise introduced this merge window
Message-Id: <5595aef728271aba37@agluck-desk.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

The following changes since commit 4da3064d1775810f10f7ddc1c34c3f1ff502a654:

  Merge tag 'devicetree-for-linus' of git://git.kernel.org/pub/scm/linux/kernel/git/glikely/linux (2015-07-01 19:40:18 -0700)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/aegl/linux.git tags/please-pull-put_kernel_page

for you to fetch changes up to 43c518d197e7758bc64e0485050de347797faab6:

  [IA64] Drop debug test/printk that some special pages are marked reserved (2015-07-02 14:30:33 -0700)

----------------------------------------------------------------
remove some boot noise from a now-invalid check that pages are reserved

----------------------------------------------------------------
Tony Luck (1):
      [IA64] Drop debug test/printk that some special pages are marked reserved

 arch/ia64/mm/init.c | 4 ----
 1 file changed, 4 deletions(-)
