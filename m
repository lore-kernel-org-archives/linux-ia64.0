From: Yinghai Lu <yinghai@kernel.org>
Date: Fri, 26 Jul 2013 12:42:11 +0000
Subject: Re: [PATCH 1/2] PCI: hotplug: Convert to be builtin only, not modular
Message-Id: <CAE9FiQVNYB7z7e1s=1PGsgQe_kexy+7V10WAxkReA-kiQ=10yg@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20130725175242.6006.56007.stgit@bhelgaas-glaptop>
	<20130725175720.6006.96448.stgit@bhelgaas-glaptop>
In-Reply-To: <20130725175720.6006.96448.stgit@bhelgaas-glaptop>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Bjorn Helgaas <bhelgaas@google.com>
Cc: "linux-pci@vger.kernel.org" <linux-pci@vger.kernel.org>, Fenghua Yu <fenghua.yu@intel.com>, Tony Luck <tony.luck@intel.com>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, linux-sh@vger.kernel.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>, "Rafael J. Wysocki" <rjw@sisk.pl>, Paul Mundt <lethal@linux-sh.org>, Paul Mackerras <paulus@samba.org>, linuxppc-dev@lists.ozlabs.org

On Thu, Jul 25, 2013 at 10:57 AM, Bjorn Helgaas <bhelgaas@google.com> wrote:
> Convert CONFIG_HOTPLUG_PCI from tristate to bool.  This only affects
> the hotplug core; several of the hotplug drivers can still be modules.
>
> Signed-off-by: Bjorn Helgaas <bhelgaas@google.com>
> ---
>  arch/ia64/configs/generic_defconfig    |    2 +-
>  arch/ia64/configs/gensparse_defconfig  |    2 +-
>  arch/ia64/configs/tiger_defconfig      |    2 +-
>  arch/ia64/configs/xen_domu_defconfig   |    2 +-
>  arch/powerpc/configs/ppc64_defconfig   |    2 +-
>  arch/powerpc/configs/ppc64e_defconfig  |    2 +-
>  arch/powerpc/configs/pseries_defconfig |    2 +-
>  arch/sh/configs/sh03_defconfig         |    2 +-
>  drivers/pci/hotplug/Kconfig            |    5 +----
>  9 files changed, 9 insertions(+), 12 deletions(-)

Acked-by: Yinghai Lu <yinghai@kernel.org>
