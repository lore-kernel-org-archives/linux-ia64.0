From: "Luck, Tony" <tony.luck@intel.com>
Date: Wed, 28 May 2008 19:52:49 +0000
Subject: [git pull] ia64 changes
Message-Id: <1FE6DD409037234FAB833C420AA843EC016FFB66@orsmsx424.amr.corp.intel.com>
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

 arch/ia64/kernel/ivt.S         |   84 ++++++++++++++++++++--------------------
 arch/ia64/kernel/minstate.h    |   46 ++++++++++++++++++++--
 arch/ia64/kernel/patch.c       |   23 +++++++++++
 arch/ia64/kernel/setup.c       |   11 +++++
 arch/ia64/kernel/vmlinux.lds.S |    7 +++
 include/asm-ia64/patch.h       |    1 +
 include/asm-ia64/ptrace.h      |    2 +-
 include/asm-ia64/sections.h    |    1 +
 8 files changed, 128 insertions(+), 47 deletions(-)

Tony Luck (1):
      [IA64] Workaround for RSE issue



