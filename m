From: "Luck, Tony" <tony.luck@intel.com>
Date: Sat, 14 Aug 2010 04:04:34 +0000
Subject: [git pull] ia64 changes
Message-Id: <4c6615d21509583814@agluck-desktop.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1FE6DD409037234FAB833C420AA843EC0122AEB1@orsmsx424.amr.corp.intel.com>
In-Reply-To: <1FE6DD409037234FAB833C420AA843EC0122AEB1@orsmsx424.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi Linus,

please pull from:

	git://git.kernel.org/pub/scm/linux/kernel/git/aegl/linux-2.6.git release

This will update the files shown below.  Final fix for the rwsem
problem. Also the three new syscalls for this release.

Thanks!

-Tony

 arch/ia64/include/asm/atomic.h |    8 ++++----
 arch/ia64/include/asm/unistd.h |    5 ++++-
 arch/ia64/kernel/entry.S       |    3 +++
 3 files changed, 11 insertions(+), 5 deletions(-)

Tony Luck (2):
      [IA64] Fix 64-bit atomic routines to return "long"
      [IA64] Add latest crop of syscalls

