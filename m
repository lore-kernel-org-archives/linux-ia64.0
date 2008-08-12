From: "Luck, Tony" <tony.luck@intel.com>
Date: Tue, 12 Aug 2008 21:55:58 +0000
Subject: [git pull] ia64 changes
Message-Id: <200808122155.m7CLtwDB005156@agluck-lia64.sc.intel.com>
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

 arch/ia64/include/asm/sal.h    |    2 +-
 arch/ia64/kernel/head.S        |   26 +++++++++++++++++++++++++-
 arch/ia64/kernel/setup.c       |   18 ++++++++++--------
 arch/ia64/kernel/smpboot.c     |    2 ++
 arch/ia64/kernel/vmlinux.lds.S |    3 +++
 arch/ia64/mm/contig.c          |   10 ++++++++--
 arch/ia64/mm/discontig.c       |    6 +++++-
 7 files changed, 54 insertions(+), 13 deletions(-)

Adrian Bunk (1):
      [IA64] use bcd2bin/bin2bcd

Tony Luck (1):
      [IA64] Ensure cpu0 can access per-cpu variables in early boot code

