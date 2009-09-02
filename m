From: "Luck, Tony" <tony.luck@intel.com>
Date: Wed, 02 Sep 2009 17:28:23 +0000
Subject: [git pull] ia64 changes
Message-Id: <4a9eab37542339bc0@agluck-desktop.sc.intel.com>
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

 arch/ia64/kernel/dma-mapping.c |    4 +++-
 arch/ia64/lib/ip_fast_csum.S   |    8 +++++---
 2 files changed, 8 insertions(+), 4 deletions(-)

Jiri Bohac (1):
      [IA64] fix csum_ipv6_magic()

Tony Luck (1):
      [IA64] Fix warning in dma-mapping.c

