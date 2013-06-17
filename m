From: "Luck, Tony" <tony.luck@intel.com>
Date: Mon, 17 Jun 2013 20:47:22 +0000
Subject: [GIT PULL] Fix ia64 build breakage
Message-Id: <51bf75da154314b73f@agluck-desk.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <4bff019827164eea63@agluck-desktop.sc.intel.com>
In-Reply-To: <4bff019827164eea63@agluck-desktop.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

The following changes since commit 8177a9d79c0e942dcac3312f15585d0344d505a5:

  lseek(fd, n, SEEK_END) does *not* go to eof - n (2013-06-16 08:10:53 -1000)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/aegl/linux.git tags/please-pull-fixia64

for you to fetch changes up to f75773103d24faaa75323597c2804edfb4a48a52:

  [IA64] Fix include dependency in asm/irqflags.h (2013-06-17 13:39:52 -0700)

----------------------------------------------------------------
Fix ia64 build breakage by adding newly needed #include

----------------------------------------------------------------
David Daney (1):
      [IA64] Fix include dependency in asm/irqflags.h

 arch/ia64/include/asm/irqflags.h | 1 +
 1 file changed, 1 insertion(+)
