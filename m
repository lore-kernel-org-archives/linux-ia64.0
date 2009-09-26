From: "Luck, Tony" <tony.luck@intel.com>
Date: Sat, 26 Sep 2009 19:57:23 +0000
Subject: [git pull] ia64 changes
Message-Id: <4abe722316523708c9@agluck-desktop.sc.intel.com>
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

This will update the files shown below.

Thanks!

-Tony

 arch/ia64/Kconfig                      |    4 +-
 arch/ia64/include/asm/spinlock.h       |  177 ++++++++++++++++----------------
 arch/ia64/include/asm/spinlock_types.h |    2 +-
 arch/ia64/kernel/head.S                |   89 ----------------
 arch/ia64/kernel/ia64_ksyms.c          |   20 ----
 arch/ia64/oprofile/backtrace.c         |   20 +----
 6 files changed, 93 insertions(+), 219 deletions(-)

Tony Luck (1):
      [IA64] implement ticket locks for Itanium

