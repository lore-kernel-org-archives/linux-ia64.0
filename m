From: "Luck, Tony" <tony.luck@intel.com>
Date: Mon, 16 Jun 2008 17:28:55 +0000
Subject: [git pull] ia64 changes
Message-Id: <57C9024A16AD2D4C97DC78E552063EA306105AC4@orsmsx505.amr.corp.intel.com>
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

 arch/ia64/Makefile              |    1 +
 arch/ia64/kernel/perfmon.c      |   10 +++++-----
 arch/ia64/kernel/sal.c          |    7 +++----
 arch/ia64/uv/kernel/setup.c     |   12 ++++++++++++
 include/asm-ia64/sn/simulator.h |    7 ++++++-
 5 files changed, 27 insertions(+), 10 deletions(-)

Alex Chiang (1):
      [IA64] Update check_sal_cache_flush to use platform_send_ipi()

Jack Steiner (1):
      [IA64] Fix CONFIG_IA64_SGI_UV build error

stephane eranian (1):
      [IA64] perfmon: fix async exit bug



