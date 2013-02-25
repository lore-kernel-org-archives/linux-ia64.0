From: "Luck, Tony" <tony.luck@intel.com>
Date: Mon, 25 Feb 2013 18:24:30 +0000
Subject: [GIT PULL] pair of ia64 changes from -mm tree
Message-Id: <512bac5e77161c012@agluck-desk.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

The following changes since commit 19f949f52599ba7c3f67a5897ac6be14bfcb1200:

  Linux 3.8 (2013-02-18 15:58:34 -0800)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/aegl/linux.git tags/please-pull-vm_unwrapped

for you to fetch changes up to e31048af84e24c99136acaad99f9273b147f8444:

  mm: use vm_unmapped_area() in hugetlbfs on ia64 architecture (2013-02-22 13:48:24 -0800)

----------------------------------------------------------------
ia64 vm patch series that was cooking in -mm tree

----------------------------------------------------------------
Michel Lespinasse (2):
      mm: use vm_unmapped_area() on ia64 architecture
      mm: use vm_unmapped_area() in hugetlbfs on ia64 architecture

 arch/ia64/kernel/sys_ia64.c | 37 ++++++++++++-------------------------
 arch/ia64/mm/hugetlbpage.c  | 20 +++++++++-----------
 2 files changed, 21 insertions(+), 36 deletions(-)
