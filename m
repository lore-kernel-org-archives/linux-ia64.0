From: "Luck, Tony" <tony.luck@intel.com>
Date: Fri, 22 Feb 2013 17:38:26 +0000
Subject: [GIT PULL] Fix ia64 build breakage
Message-Id: <5127ad1219167029@agluck-desk.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <4bff019827164eea63@agluck-desktop.sc.intel.com>
In-Reply-To: <4bff019827164eea63@agluck-desktop.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, Clark Williams <clark.williams@gmail.com>

The following changes since commit 2ef14f465b9e096531343f5b734cffc5f759f4a6:

  Merge branch 'x86-mm-for-linus' of git://git.kernel.org/pub/scm/linux/kernel/git/tip/tip (2013-02-21 18:06:55 -0800)

are available in the git repository at:


  git://git.kernel.org/pub/scm/linux/kernel/git/aegl/linux.git tags/please-pull-fix-ia64-build

for you to fetch changes up to bc681593b588786e6326b3e5f78ccc1683e2269c:

  sched: move RR_TIMESLICE from sysctl.h to rt.h (2013-02-22 09:20:11 -0800)

----------------------------------------------------------------
Fix ia64 build

----------------------------------------------------------------
Clark Williams (1):
      sched: move RR_TIMESLICE from sysctl.h to rt.h

 include/linux/sched/rt.h     | 6 ++++++
 include/linux/sched/sysctl.h | 6 ------
 2 files changed, 6 insertions(+), 6 deletions(-)
