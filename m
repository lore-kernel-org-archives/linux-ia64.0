From: "Luck, Tony" <tony.luck@intel.com>
Date: Tue, 26 Aug 2008 16:59:30 +0000
Subject: [git pull] ia64 changes
Message-Id: <200808261659.m7QGxUnG007771@agluck-lia64.sc.intel.com>
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

 arch/ia64/include/asm/io.h |   10 ++++++----
 arch/ia64/kernel/smpboot.c |    1 +
 2 files changed, 7 insertions(+), 4 deletions(-)

James Bottomley (1):
      [IA64] Fix __{in,out}s{w,l} to handle unaligned data

Robin Holt (1):
      [IA64] Fix ia64 build failure when CONFIG_SFC=m

