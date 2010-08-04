From: "Luck, Tony" <tony.luck@intel.com>
Date: Wed, 04 Aug 2010 16:09:56 +0000
Subject: [git pull] ia64 changes
Message-Id: <4c5990d411458be634@agluck-desktop.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1FE6DD409037234FAB833C420AA843EC0122AEB1@orsmsx424.amr.corp.intel.com>
In-Reply-To: <1FE6DD409037234FAB833C420AA843EC0122AEB1@orsmsx424.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

Hi Linus,

please pull from:

	git://git.kernel.org/pub/scm/linux/kernel/git/aegl/linux-2.6.git release

This will update the files shown below.

Thanks!

-Tony

 arch/ia64/configs/bigsur_defconfig    | 1428 ++------------------------
 arch/ia64/configs/generic_defconfig   | 1788 ++++-------------------------=
----
 arch/ia64/configs/gensparse_defconfig | 1493 +++------------------------
 arch/ia64/configs/sim_defconfig       |  756 +-------------
 arch/ia64/configs/tiger_defconfig     | 1356 +++----------------------
 arch/ia64/configs/xen_domu_defconfig  | 1678 +++--------------------------=
--
 arch/ia64/configs/zx1_defconfig       | 1681 +++--------------------------=
---
 arch/ia64/include/asm/page.h          |    2 +-
 arch/ia64/kernel/perfmon.c            |   22 +-
 arch/ia64/kernel/vmlinux.lds.S        |  362 ++++----
 10 files changed, 1058 insertions(+), 9508 deletions(-)

Arnd Bergmann (1):
      [IA64] perfmon: convert to unlocked_ioctl

Sam Ravnborg (1):
      [IA64] beautify vmlinux.lds.h

Tony Luck (2):
      [IA64] Put ia64 config files on the Uwe Kleine-K=C3=B6nig diet
      [IA64] increase ia64 static per cpu area

