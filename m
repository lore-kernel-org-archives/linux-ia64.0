From: "Luck, Tony" <tony.luck@intel.com>
Date: Tue, 19 Nov 2013 22:52:07 +0000
Subject: [GIT PULL] Unbreak the ia64 build
Message-Id: <528beb972986965d4@agluck-desk.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org

The following changes since commit dec8e46178bad9f1717a948572d76e0f804be801:

  Merge tag 'arc-v3.13-rc1-part2' of git://git.kernel.org/pub/scm/linux/kernel/git/vgupta/arc (2013-11-19 11:44:15 -0800)

are available in the git repository at:


  git://git.kernel.org/pub/scm/linux/kernel/git/aegl/linux.git tags/please-pull-fixia64

for you to fetch changes up to 24b9fdc59ac365e7e313e5af44c7bfe31c15c774:

  kernel/bounds: avoid circular dependencies in generated headers (2013-11-19 14:20:12 -0800)

----------------------------------------------------------------
Unbreak ia64 build by avoiding circular dependency

----------------------------------------------------------------
Kirill A. Shutemov (1):
      kernel/bounds: avoid circular dependencies in generated headers

 kernel/bounds.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)
