From: "Luck, Tony" <tony.luck@intel.com>
Date: Tue, 23 Sep 2008 16:59:14 +0000
Subject: [git pull] ia64 changes
Message-Id: <200809231659.m8NGxEiE000830@agluck-lia64.sc.intel.com>
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

 arch/ia64/kernel/efi.c   |    5 +++--
 arch/ia64/kernel/setup.c |    2 ++
 2 files changed, 5 insertions(+), 2 deletions(-)

Alex Chiang (1):
      [IA64] Ski simulator doesn't need check_sal_cache_flush

Jay Lan (1):
      [IA64] kexec fails on systems with blocks of uncached memory

