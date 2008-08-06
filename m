From: "Luck, Tony" <tony.luck@intel.com>
Date: Wed, 06 Aug 2008 18:32:56 +0000
Subject: [git pull] ia64 changes
Message-Id: <57C9024A16AD2D4C97DC78E552063EA3083839C5@orsmsx505.amr.corp.intel.com>
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

 arch/ia64/Kconfig                   |   10 +-
 arch/ia64/configs/generic_defconfig |  586 ++++++++++++++++++++++-------------
 arch/ia64/kernel/.gitignore         |    1 +
 arch/ia64/kernel/ivt.S              |    4 +-
 drivers/misc/Kconfig                |    4 +-
 5 files changed, 381 insertions(+), 224 deletions(-)

Isaku Yamahata (1):
      [IA64] pv_ops: fix ivt.S paravirtualization

Jack Steiner (1):
      [IA64] Eliminate trailing backquote in IA64_SGI_UV

Robin Holt (4):
      [IA64] Cleanup generated file not ignored by .gitignore
      [IA64] Allow ia64 to CONFIG_NR_CPUS up to 4096
      [IA64] update generic_defconfig for 2.6.27-rc1
      [IA64] update generic_defconfig to support sn2.

Tony Luck (2):
      [IA64] Fix uniprocessor build w.r.t. SGI_XP and SGI_GRU
      [IA64] Update generic config



