From: "Luck, Tony" <tony.luck@intel.com>
Date: Wed, 25 Feb 2009 22:44:10 +0000
Subject: [git pull] ia64 changes
Message-Id: <49a5c9ba26947c25c0@agluck-desktop.sc.intel.com>
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

 arch/ia64/Kconfig          |   11 +++++++++++
 arch/ia64/kernel/iosapic.c |    2 +-
 arch/ia64/kernel/unwind.c  |    2 +-
 3 files changed, 13 insertions(+), 2 deletions(-)

Kyle McMartin (1):
      [IA64] enable setting DMAR on by default

Roel Kluin (2):
      [IA64] Do not go beyond ARRAY_SIZE of unw.hash
      [IA64] Don't go beyond iosapic_intr_info's arraysize

