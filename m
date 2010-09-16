From: "Luck, Tony" <tony.luck@intel.com>
Date: Thu, 16 Sep 2010 15:57:16 +0000
Subject: [git pull] ia64 changes
Message-Id: <4c923e5c170564a0cc@agluck-desktop.sc.intel.com>
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

 arch/ia64/kernel/fsys.S |   42 +++++++++++-------------------------------
 1 files changed, 11 insertions(+), 31 deletions(-)

Petr Tesarik (1):
      [IA64] Optimize ticket spinlocks in fsys_rt_sigprocmask

