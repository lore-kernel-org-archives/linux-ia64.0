From: Grant Grundler <grundler@parisc-linux.org>
Date: Thu, 12 Jan 2006 04:53:41 +0000
Subject: Re: [PATCH 1/3] msi vector targeting abstractions
Message-Id: <20060112050243.GC332@colo.lackof.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060111155251.12460.71269.12163@attica.americas.sgi.com> <20060111155256.12460.26048.32596@attica.americas.sgi.com>
In-Reply-To: <20060111155256.12460.26048.32596@attica.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Mark Maule <maule@sgi.com>
Cc: linuxppc64-dev@ozlabs.org, linux-pci@atrey.karlin.mff.cuni.cz, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, Tony Luck <tony.luck@intel.com>, gregkh@suse.de

On Wed, Jan 11, 2006 at 09:52:56AM -0600, Mark Maule wrote:
> Abstract portions of the MSI core for platforms that do not use standard
> APIC interrupt controllers.  This is implemented through a new arch-specific
> msi setup routine, and a set of msi ops which can be set on a per platform
> basis.
...
> Index: linux-maule/drivers/pci/msi.c
...
> +	if ((status = msi_arch_init()) < 0) {

Willy told me I should always complain about assignment in if() statements :)

Greg, I volunteer to submit a patch to fix all occurances in pci/msi.c
including the one above.  I can prepare that this weekend on my own time.
Is that ok?

grant
