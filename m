From: David Daney <ddaney.cavm@gmail.com>
Date: Tue, 07 Oct 2014 16:59:29 +0000
Subject: Re: [PATCH 05/44] mfd: as3722: Drop reference to pm_power_off from devicetree bindings
Message-Id: <54341BF1.9020001@gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1412659726-29957-1-git-send-email-linux@roeck-us.net>
 <1412659726-29957-6-git-send-email-linux@roeck-us.net>
 <543412F7.8040909@landley.net> <20141007163131.GE28835@roeck-us.net>
In-Reply-To: <20141007163131.GE28835@roeck-us.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Guenter Roeck <linux@roeck-us.net>, Rob Landley <rob@landley.net>
Cc: linux-m32r-ja@ml.linux-m32r.org, linux-mips@linux-mips.org, linux-efi@vger.kernel.org, linux-ia64@vger.kernel.org, linux-xtensa@linux-xtensa.org, Mark Rutland <mark.rutland@arm.com>, devel@driverdev.osuosl.org, linux-s390@vger.kernel.org, lguest@lists.ozlabs.org, linux-c6x-dev@linux-c6x.org, linux-hexagon@vger.kernel.org, linux-sh@vger.kernel.org, linux-acpi@vger.kernel.org, Pawel Moll <pawel.moll@arm.com>, xen-devel@lists.xenproject.org, devicetree@vger.kernel.org, user-mode-linux-devel@lists.sourceforge.net, linux-pm@vger.kernel.org, adi-buildroot-devel@lists.sourceforge.net, linux-m68k@lists.linux-m68k.org, linux-am33-list@redhat.com, linux-tegra@vger.kernel.org, openipmi-developer@lists.sourceforge.net, linux-metag@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-parisc@vger.kernel.org, linux-cris-kernel@axis.com, linux-kernel@vger.kernel.org

On 10/07/2014 09:31 AM, Guenter Roeck wrote:
> On Tue, Oct 07, 2014 at 11:21:11AM -0500, Rob Landley wrote:
>> On 10/07/14 00:28, Guenter Roeck wrote:
>>> Devicetree bindings are supposed to be operating system independent
>>> and should thus not describe how a specific functionality is implemented
>>> in Linux.
>>
>> So your argument is that linux/Documentation/devicetree/bindings should
>> not be specific to Linux. Merely hosted in the Linux kernel source
>> repository.
>>
>> Well that's certainly a point of view.
>>
> Not specifically my argument, really, and nothing new either. But, yes, I do
> think that devicetree bindings descriptions should not include implementation
> details, especially since those may change over time (as is the case here).
>

I fully agree.

Many device trees come from outside the kernel (i.e. they are supplied 
by the system boot environment).  Obviously these device trees cannot be 
changed at the whim of kernel developers, *and* it is perfectly 
reasonable to think that software other than the Linux kernel will run 
on this type of system too.

So yes, it is really true, device trees are not a Linux kernel private 
implementation detail, they are really an external ABI that, although 
documented in the kernel source tree, cannot be changed in incompatible 
ways as time progresses.

David Daney



