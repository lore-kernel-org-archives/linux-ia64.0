From: Rob Landley <rob@landley.net>
Date: Tue, 07 Oct 2014 17:10:58 +0000
Subject: Re: [PATCH 05/44] mfd: as3722: Drop reference to pm_power_off from devicetree bindings
Message-Id: <54341EA2.6010806@landley.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <1412659726-29957-1-git-send-email-linux@roeck-us.net> <1412659726-29957-6-git-send-email-linux@roeck-us.net> <543412F7.8040909@landley.net> <20141007163131.GE28835@roeck-us.net> <54341BF1.9020001@gmail.com>
In-Reply-To: <54341BF1.9020001-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: David Daney <ddaney.cavm-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Guenter Roeck <linux-0h96xk9xTtrk1uMJSBkQmQ@public.gmane.org>
Cc: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, adi-buildroot-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org, devel-gWbeCf7V1WCQmaza687I9mD2FQJk+8+b@public.gmane.org, devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, lguest-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org, linux-acpi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-alpha-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-am33-list-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, linux-cris-kernel-VrBV9hrLPhE@public.gmane.org, linux-efi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-hexagon-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-m32r-ja-rQhvJZKUsGBRYuoOT4C5/9i2O/JbrIOy@public.gmane.org, linuxppc-dev-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org, linux-s390-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-tegra-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-xtensa-PjhNF2WwrV/0Sa2dR60CXw@public.gmane.org, openipmi-developer-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org, user-mode-linux-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org, linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, linux-c6x-dev-jPsnJVOj+W6hPH1hqNUYSQ@public.gmane.org, linux-ia64-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-m68k-cunTk1MwBs8S/qaLPR03pWD2FQJk+8+b@public.gmane.org, linux-metag-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-mips-6z/3iImG2C8G8FEW9MqTrA@public.gmane.org, linux-parisc-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-pm-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-sh-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, xen-devel-GuqFBffKawtpuQazS67q72D2FQJk+8+b@public.gmane.org, Rob Herring <robh+>

On 10/07/14 11:59, David Daney wrote:
> On 10/07/2014 09:31 AM, Guenter Roeck wrote:
>> On Tue, Oct 07, 2014 at 11:21:11AM -0500, Rob Landley wrote:
>>> On 10/07/14 00:28, Guenter Roeck wrote:
>>>> Devicetree bindings are supposed to be operating system independent
>>>> and should thus not describe how a specific functionality is
>>>> implemented
>>>> in Linux.
>>>
>>> So your argument is that linux/Documentation/devicetree/bindings should
>>> not be specific to Linux. Merely hosted in the Linux kernel source
>>> repository.
>>>
>>> Well that's certainly a point of view.
>>>
>> Not specifically my argument, really, and nothing new either. But,
>> yes, I do
>> think that devicetree bindings descriptions should not include
>> implementation
>> details, especially since those may change over time (as is the case
>> here).
>>
> 
> I fully agree.
> 
> Many device trees come from outside the kernel (i.e. they are supplied
> by the system boot environment).  Obviously these device trees cannot be
> changed at the whim of kernel developers, *and* it is perfectly
> reasonable to think that software other than the Linux kernel will run
> on this type of system too.
> 
> So yes, it is really true, device trees are not a Linux kernel private
> implementation detail, they are really an external ABI that, although
> documented in the kernel source tree, cannot be changed in incompatible
> ways as time progresses.

Ah. Existing thing with backstory among the in-crowd, so I'll assume
"git subtree" was previously suggested and you had that discussion
already and decided against it.

Carry on,

Rob
