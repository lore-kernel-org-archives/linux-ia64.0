From: Ingo Molnar <mingo@kernel.org>
Date: Sat, 07 Oct 2017 08:58:58 +0000
Subject: Re: [PATCH 0/4] PCI: Cleanup unused stuff
Message-Id: <20171007085858.hjjowcgm457wo3cg@gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20171005201939.18300.25690.stgit@bhelgaas-glaptop.roam.corp.google.com>
In-Reply-To: <20171005201939.18300.25690.stgit@bhelgaas-glaptop.roam.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Bjorn Helgaas <helgaas@kernel.org>
Cc: linux-pci@vger.kernel.org, linux-mips@linux-mips.org, Rich Felker <dalias@libc.org>, linux-ia64@vger.kernel.org, linux-sh@vger.kernel.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>, David Howells <dhowells@redhat.com>, Max Filippov <jcmvbkbc@gmail.com>, Paul Mackerras <paulus@samba.org>, "H. Peter Anvin" <hpa@zytor.com>, sparclinux@vger.kernel.org, Jesper Nilsson <jesper.nilsson@axis.com>, linux-am33-list@redhat.com, Yoshinori Sato <ysato@users.sourceforge.jp>, Michael Ellerman <mpe@ellerman.id.au>, Helge Deller <deller@gmx.de>, x86@kernel.org, "James E.J. Bottomley" <jejb@parisc-linux.org>, Ingo Molnar <mingo@redhat.com>, Matt Turner <mattst88@gmail.com>, Fenghua Yu <fenghua.yu@intel.com>, linux-xtensa@linux-xtensa.org, Mikael Starvik <starvik@axis.com>, Ivan Kokshaysky <ink@jurassic.park.msu.ru>, Thomas Gleixner <tglx@linutronix.de>, Richard Henderson <rth@twiddle.net>, Chris Zankel <chris@zankel.net>, Tony Luck <tony.luck@intel.com>, linux-cris-kernel@axis.com, linux-parisc@vger.kernel.org, Ralf Baechle <ralf@linux-mips.org>, linux-alpha@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, "David S. Miller" <davem@davemloft.net>


* Bjorn Helgaas <helgaas@kernel.org> wrote:

> Sorry for the long cc list.  These are pretty trivial; they just remove
> some unnecessary declarations across several arches.
> 
> ---
> 
> Bjorn Helgaas (4):
>       PCI: Remove redundant pcibios_set_master() declarations
>       PCI: Remove redundant pci_dev, pci_bus, resource declarations
>       PCI: Remove unused declarations
>       alpha/PCI: Make pdev_save_srm_config() static
> 
> 
>  arch/alpha/include/asm/pci.h            |    5 -----
>  arch/alpha/kernel/pci.c                 |   11 ++++++++++-
>  arch/alpha/kernel/pci_impl.h            |    8 --------
>  arch/cris/include/asm/pci.h             |    9 ---------
>  arch/frv/include/asm/pci.h              |    4 ----
>  arch/ia64/include/asm/pci.h             |    4 ----
>  arch/mips/include/asm/pci.h             |    4 ----
>  arch/mn10300/include/asm/pci.h          |    4 ----
>  arch/mn10300/unit-asb2305/pci-asb2305.h |    3 ---
>  arch/parisc/include/asm/pci.h           |    8 --------
>  arch/powerpc/include/asm/pci.h          |    2 --
>  arch/sh/include/asm/pci.h               |    4 ----
>  arch/sparc/include/asm/pci_32.h         |    2 --
>  arch/x86/include/asm/pci.h              |    2 --
>  arch/xtensa/include/asm/pci.h           |    2 --
>  15 files changed, 10 insertions(+), 62 deletions(-)

Nice cleanups! For the whole series:

  Reviewed-by: Ingo Molnar <mingo@kernel.org>

Thanks,

	Ingo
