From: "Luck, Tony" <tony.luck@intel.com>
Date: Tue, 24 Jun 2008 21:49:55 +0000
Subject: [git pull] ia64 changes
Message-Id: <57C9024A16AD2D4C97DC78E552063EA3062D27EA@orsmsx505.amr.corp.intel.com>
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

 arch/ia64/kernel/iosapic.c        |    2 --
 arch/ia64/kernel/setup.c          |    3 +--
 arch/ia64/sn/kernel/sn2/sn2_smp.c |    2 +-
 3 files changed, 2 insertions(+), 5 deletions(-)

Cliff Wickman (1):
      [IA64] Handle count=0 in sn2_ptc_proc_write()

Jes Sorensen (1):
      [IA64] Fix boot failure on ia64/sn2

Julia Lawall (1):
      [IA64] Eliminate NULL test after alloc_bootmem in iosapic_alloc_rte()



