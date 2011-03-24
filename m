From: "Luck, Tony" <tony.luck@intel.com>
Date: Thu, 24 Mar 2011 16:29:44 +0000
Subject: [git pull] ia64 changes
Message-Id: <4d8b71781902177d76@agluck-desktop.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1FE6DD409037234FAB833C420AA843EC0122AEB1@orsmsx424.amr.corp.intel.com>
In-Reply-To: <1FE6DD409037234FAB833C420AA843EC0122AEB1@orsmsx424.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org

Hi Linus,

please pull from:

	git://git.kernel.org/pub/scm/linux/kernel/git/aegl/linux-2.6.git release

This will update the files shown below.

Thanks!

-Tony

 arch/ia64/include/asm/unistd.h |    6 +++++-
 arch/ia64/kernel/entry.S       |    4 ++++
 fs/pstore/platform.c           |   15 ++++++++++++---
 3 files changed, 21 insertions(+), 4 deletions(-)

Tony Luck (2):
      [IA64] New syscalls for 2.6.39
      pstore: cleanups to pstore_dump()

