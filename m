From: ebiederm@xmission.com (Eric W. Biederman)
Date: Thu, 05 Aug 2004 02:14:55 +0000
Subject: Re: [Fastboot] Re: [BROKEN PATCH] kexec for ia64
Message-Id: <m1hdri2uw0.fsf@ebiederm.dsl.xmission.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200407261524.40804.jbarnes@engr.sgi.com>
	<200407261536.05133.jbarnes@engr.sgi.com>
	<20040730155504.2a51b1fa.rddunlap@osdl.org>
	<m18ycvhx1j.fsf@ebiederm.dsl.xmission.com>
	<20040804233335.GD548@cup.hp.com>
In-Reply-To: <20040804233335.GD548@cup.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Grant Grundler <iod00d@hp.com>
Cc: "Randy.Dunlap" <rddunlap@osdl.org>, linux-ia64@vger.kernel.org, Jesse Barnes <jbarnes@engr.sgi.com>, linux-kernel@vger.kernel.org, fastboot@osdl.org

Grant Grundler <iod00d@hp.com> writes:

> On Wed, Aug 04, 2004 at 07:07:04AM -0600, Eric W. Biederman wrote:
> > Initially that patch
> > was targeted for a kernel without device_shutdown(), so I was
> > likely considering the old trick of running through all of the PCI
> > devices and disabling their bus master bit.
> 
> Blindly disabling all PCI bus master bits will also kill VGA/serial
> console and any USB keyboard attached to the system.

VGA/serial console devices rarely need to do be bus masters so they
should be fine.

> I'll comment more on the "DMA is a Red Herring" when I can read
> more what it is about.

Most of those cases don't matter as the driver should always be calling
pci_set_master() on startup.  Disabling all the bus master bits on ioxapics
in pci space would likely cripple the system.  As they are architectural
hardware and rarely have pci drivers that can enable them.

In the general case it appears to be overkill, incorrect and
insufficient to disable bus mastering on all PCI devices.  Which is
why device_shutdown() calls device specific code.

Eric
