From: "Luck, Tony" <tony.luck@intel.com>
Date: Thu, 05 Jan 2012 17:42:31 +0000
Subject: [git pull] ia64 changes
Message-Id: <4f05e10721849ff63@agluck-desktop.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1FE6DD409037234FAB833C420AA843EC0122AEB1@orsmsx424.amr.corp.intel.com>
In-Reply-To: <1FE6DD409037234FAB833C420AA843EC0122AEB1@orsmsx424.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

Hi Linus,

please pull from:

	git://git.kernel.org/pub/scm/linux/kernel/git/aegl/linux.git misc-3.3
	HEAD=A4b1d1b3619ee2fac40cdf5ca86a4758e45b9358

This will update the files shown below.

Thanks!

-Tony

[Confession time: These commits haven't been exposed to linux-next, because=
 I
 failed to merge the misc-3.3 branch into my "next" branch for Stephen to p=
ick up :-(
 But it isn't like there's a huge population of ia64 testers checking every
 linux-next release. Petr's fix has seen some testing in the SLES11-SP2-RC =
series
 the other three are just semantic sugar]

 arch/ia64/kernel/setup.c                |   19 +++++++++++++++++++
 arch/ia64/sn/kernel/irq.c               |    5 ++---
 arch/ia64/sn/pci/pcibr/pcibr_provider.c |    3 +--
 arch/ia64/sn/pci/tioca_provider.c       |    4 ++--
 4 files changed, 24 insertions(+), 7 deletions(-)

Petr Tesarik (1):
      [IA64] Merge overlapping reserved regions at boot

Thomas Meyer (3):
      ia64: tioca: Use kmemdup rather than duplicating its implementation
      ia64: sn: Use kmemdup rather than duplicating its implementation
      ia64: pcibr: Use kmemdup rather than duplicating its implementation

