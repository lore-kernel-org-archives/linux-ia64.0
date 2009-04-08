From: "Luck, Tony" <tony.luck@intel.com>
Date: Wed, 08 Apr 2009 22:33:24 +0000
Subject: [git pull] ia64 changes
Message-Id: <49dd26342260662862@agluck-desktop.sc.intel.com>
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

 arch/ia64/include/asm/unistd.h |    4 +++-
 arch/ia64/kernel/entry.S       |    2 ++
 2 files changed, 5 insertions(+), 1 deletions(-)

Tony Luck (1):
      [IA64] wire up preadv/pwritev system calls

