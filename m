From: "Luck, Tony" <tony.luck@intel.com>
Date: Tue, 30 Sep 2008 16:18:38 +0000
Subject: [git pull] ia64 changes
Message-Id: <200809301618.m8UGIcuk005874@agluck-lia64.sc.intel.com>
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

 arch/ia64/include/asm/sections.h |    3 +++
 arch/ia64/kernel/head.S          |    9 +++++----
 arch/ia64/kernel/vmlinux.lds.S   |    8 +++++---
 arch/ia64/mm/contig.c            |    2 +-
 arch/ia64/mm/discontig.c         |    2 +-
 5 files changed, 15 insertions(+), 9 deletions(-)

Tony Luck (1):
      [IA64] Put the space for cpu0 per-cpu area into .data section

