From: "Luck, Tony" <tony.luck@intel.com>
Date: Tue, 05 May 2009 22:42:01 +0000
Subject: [git pull] ia64 changes
Message-Id: <4a00c0b917731a9b7@agluck-desktop.sc.intel.com>
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

 arch/ia64/include/asm/idle.h       |    7 +++++++
 arch/ia64/include/asm/xen/events.h |    7 +------
 arch/ia64/xen/xensetup.S           |    2 --
 drivers/xen/balloon.c              |    3 ++-
 4 files changed, 10 insertions(+), 9 deletions(-)
 create mode 100644 arch/ia64/include/asm/idle.h

Jan Beulich (1):
      [IA64] xen_domu_defconfig: fix build issues/warnings

