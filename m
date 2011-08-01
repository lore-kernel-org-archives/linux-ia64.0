From: "Luck, Tony" <tony.luck@intel.com>
Date: Mon, 01 Aug 2011 16:57:14 +0000
Subject: [git pull] ia64 changes
Message-Id: <4e36daea25318879b1@agluck-desktop.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1FE6DD409037234FAB833C420AA843EC0122AEB1@orsmsx424.amr.corp.intel.com>
In-Reply-To: <1FE6DD409037234FAB833C420AA843EC0122AEB1@orsmsx424.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi Linus,

please pull from:

	git://git.kernel.org/pub/scm/linux/kernel/git/aegl/linux-2.6.git gpiolib

This will update the files shown below.

Thanks!

-Tony

 arch/ia64/Kconfig            |    4 +++
 arch/ia64/include/asm/gpio.h |   55 ++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 59 insertions(+), 0 deletions(-)
 create mode 100644 arch/ia64/include/asm/gpio.h

Mark Brown (1):
      [IA64] Hook up gpiolib support

