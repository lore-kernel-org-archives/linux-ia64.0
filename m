From: "Luck, Tony" <tony.luck@intel.com>
Date: Wed, 02 Nov 2011 21:06:53 +0000
Subject: [git pull] ia64 changes
Message-Id: <4eb1b0ed11641336d1@agluck-desktop.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1FE6DD409037234FAB833C420AA843EC0122AEB1@orsmsx424.amr.corp.intel.com>
In-Reply-To: <1FE6DD409037234FAB833C420AA843EC0122AEB1@orsmsx424.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

Hi Linus,

please pull from:

	git://git.kernel.org/pub/scm/linux/kernel/git/aegl/linux.git misc-3.2
	HEADk1c70b1ff6f800f081a6bbef662789135f7b398

This will update the files shown below.

Thanks!

-Tony

 MAINTAINERS                           |    3 +--
 arch/ia64/Kconfig                     |    2 +-
 arch/ia64/configs/generic_defconfig   |    1 +
 arch/ia64/configs/gensparse_defconfig |    1 +
 arch/ia64/configs/tiger_defconfig     |    1 +
 arch/ia64/configs/xen_domu_defconfig  |    1 +
 arch/ia64/configs/zx1_defconfig       |    1 +
 arch/ia64/sn/kernel/sn2/sn_hwperf.c   |   12 ++++++++----
 drivers/char/agp/hp-agp.c             |    6 ++++--
 9 files changed, 19 insertions(+), 9 deletions(-)

Ben Hutchings (1):
      [IA64] gpio: GENERIC_GPIO default must be n

Tony Luck (3):
      [IA64] sn2: add missing put_cpu()
      [IA64[ add CONFIG_NET_VENDOR_INTEL=3Dy to default config files where =
needed
      MAINTAINERS: Update entry for IA64

=C3=89meric Maschino (1):
      [IA64] agp/hp-agp: Allow binding user memory to the AGP GART

