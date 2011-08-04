From: "Luck, Tony" <tony.luck@intel.com>
Date: Thu, 04 Aug 2011 23:31:39 +0000
Subject: [git pull] ia64 changes (fix 2 compile warnings)
Message-Id: <4e3b2bdb641368cb@agluck-desktop.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi Linus,

please pull from:

	git://git.kernel.org/pub/scm/linux/kernel/git/aegl/linux-2.6.git fixefi

This will update the files shown below.

Thanks!

-Tony

 arch/ia64/kernel/efi.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

Matthew Garrett (1):
      efi: Fix argument types for SetVariable() for ia64

