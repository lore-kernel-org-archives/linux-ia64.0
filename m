From: "Luck, Tony" <tony.luck@intel.com>
Date: Fri, 08 Jan 2010 19:24:57 +0000
Subject: [git pull] ia64 changes
Message-Id: <4b47868949643d14d@agluck-desktop.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1FE6DD409037234FAB833C420AA843EC0122AEB1@orsmsx424.amr.corp.intel.com>
In-Reply-To: <1FE6DD409037234FAB833C420AA843EC0122AEB1@orsmsx424.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi Linus,

Pull again from my tree to get the fix to move the fnptr definition
as you suggested:

	git://git.kernel.org/pub/scm/linux/kernel/git/aegl/linux-2.6.git release

This will update the files shown below.

Thanks!

-Tony

 arch/ia64/include/asm/types.h |   10 +++++-----
 1 files changed, 5 insertions(+), 5 deletions(-)

Tony Luck (1):
      [IA64] move fnptr definition inside #ifdef __KERNEL__

