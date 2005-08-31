From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date: Wed, 31 Aug 2005 16:03:26 +0000
Subject: Re: 2.6.13 does not boot on Eiger
Message-Id: <200508311003.26685.bjorn.helgaas@hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <jefysr9gc7.fsf@sykes.suse.de>
In-Reply-To: <jefysr9gc7.fsf@sykes.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tuesday 30 August 2005 5:04 pm, Andreas Schwab wrote:
> I'm getting an MCA during early setup on Eiger, these are the last (and
> only) messages:
> 
> EFI v1.10 by HP: SALsystab=0x723feee9710 ACPI 2.0=0x723fe040000
> HCDP=0x723fe0720d0 SMBIOS=0x7fffe000
> booting generic kernel on platform hpzx1
> PCDP: v1 at 0x723fe0720d0
> Early serial console at MMIO 0xf0100005000 (options '9600n8')
> Number of logical nodes in system = 3
> Number of memory chunks in system = 34
> warning: skipping physical page 0
> warning: skipping physical page 0
> warning: skipping physical page 0
> 
> CONFIG_IA64_UNCACHED_ALLOCATOR is already disabled, and the kernel works
> fine on Tiger, so there must be some different problem.  The config is
> attached.  Note that this is already broken since at least 2.6.13-rc3, but
> 2.6.13-rc1 ist still ok.

Does the MCA log say anything useful?

I used your .config and saw an MCA in i8042_flush() (IIP in
__ia64_inb, BR0 in i8042_flush).  Can you try turning off
CONFIG_SERIO_I8042?  This was fixed a while back, but maybe
it got broken again.  And the i8042 probe happens much later
than your log indicates, so maybe you're seeing a different
problem.

P.S.  What is your firmware "acpiconfig" mode?  My eiger is
in "default" mode, in which accesses to non-existent I/O ports
cause MCAs.  But we don't officially support that yet because
of issues like this.  The supported modes allow accesses to
non-existent ports by setting either "single-pci-domain" or
"enable legacyprobe".
