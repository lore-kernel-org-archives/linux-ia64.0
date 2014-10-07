From: Guenter Roeck <linux@roeck-us.net>
Date: Tue, 07 Oct 2014 16:31:31 +0000
Subject: Re: [PATCH 05/44] mfd: as3722: Drop reference to pm_power_off from devicetree bindings
Message-Id: <20141007163131.GE28835@roeck-us.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <1412659726-29957-1-git-send-email-linux@roeck-us.net>
 <1412659726-29957-6-git-send-email-linux@roeck-us.net>
 <543412F7.8040909@landley.net>
In-Reply-To: <543412F7.8040909@landley.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Rob Landley <rob@landley.net>
Cc: linux-kernel@vger.kernel.org, adi-buildroot-devel@lists.sourceforge.net, devel@driverdev.osuosl.org, devicetree@vger.kernel.org, lguest@lists.ozlabs.org, linux-acpi@vger.kernel.org, linux-alpha@vger.kernel.org, linux-am33-list@redhat.com, linux-cris-kernel@axis.com, linux-efi@vger.kernel.org, linux-hexagon@vger.kernel.org, linux-m32r-ja@ml.linux-m32r.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, linux-tegra@vger.kernel.org, linux-xtensa@linux-xtensa.org, openipmi-developer@lists.sourceforge.net, user-mode-linux-devel@lists.sourceforge.net, linux-arm-kernel@lists.infradead.org, linux-c6x-dev@linux-c6x.org, linux-ia64@vger.kernel.org, linux-m68k@lists.linux-m68k.org, linux-metag@vger.kernel.org, linux-mips@linux-mips.org, linux-parisc@vger.kernel.org, linux-pm@vger.kernel.org, linux-sh@vger.kernel.org, xen-devel@lists.xenproject.org, Rob Herring <robh+>

On Tue, Oct 07, 2014 at 11:21:11AM -0500, Rob Landley wrote:
> On 10/07/14 00:28, Guenter Roeck wrote:
> > Devicetree bindings are supposed to be operating system independent
> > and should thus not describe how a specific functionality is implemented
> > in Linux.
> 
> So your argument is that linux/Documentation/devicetree/bindings should
> not be specific to Linux. Merely hosted in the Linux kernel source
> repository.
> 
> Well that's certainly a point of view.
> 
Not specifically my argument, really, and nothing new either. But, yes, I do
think that devicetree bindings descriptions should not include implementation
details, especially since those may change over time (as is the case here).

Thanks,
Guenter
