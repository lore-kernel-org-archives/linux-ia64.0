From: Frans Klaver <fransklaver@gmail.com>
Date: Thu, 18 Jun 2015 12:14:07 +0000
Subject: Re: [PATCH 01/44] kernel: Add support for poweroff handler call chain
Message-Id: <CAH6sp9O0B_BWS8cLSq=MoFbe3nB_45+K64gh7QMHO3meT-b14w@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1412659726-29957-1-git-send-email-linux@roeck-us.net>
	<1412659726-29957-2-git-send-email-linux@roeck-us.net>
	<55821936.4040704@codeaurora.org>
	<CAH6sp9P7rq2y_hiQPHKUP85CwnEmp87yC7Psh4=29h-pYnb_yw@mail.gmail.com>
	<5582B15B.4010205@roeck-us.net>
In-Reply-To: <5582B15B.4010205@roeck-us.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Guenter Roeck <linux@roeck-us.net>
Cc: Stephen Boyd <sboyd@codeaurora.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, linux-m32r-ja@ml.linux-m32r.org, linux-mips@linux-mips.org, linux-efi@vger.kernel.org, linux-ia64@vger.kernel.org, Heiko Stuebner <heiko@sntech.de>, linux-sh@vger.kernel.org, "devicetree@vger.kernel.org" <devicetree@vger.kernel.org>, Pavel Machek <pavel@ucw.cz>, devel@driverdev.osuosl.org, linux-s390@vger.kernel.org, lguest@lists.ozlabs.org, linux-c6x-dev@linux-c6x.org, linux-hexagon@vger.kernel.org, Alexander Graf <agraf@suse.de>, linux-acpi <linux-acpi@vger.kernel.org>, Geert Uytterhoeven <geert@linux-m68k.org>, xen-devel@lists.xenproject.org, Len Brown <len.brown@intel.com>, user-mode-linux-devel@lists.sourceforge.net, "linux-pm@vger.kernel.org" <linux-pm@vger.kernel.org>, linux-xtensa@linux-xtensa.org, adi-buildroot-devel@lists.sourceforge.net, linux-m68k@lists.lin

On Thu, Jun 18, 2015 at 1:54 PM, Guenter Roeck <linux@roeck-us.net> wrote:
> On 06/17/2015 11:53 PM, Frans Klaver wrote:
>>
>> On Thu, Jun 18, 2015 at 3:04 AM, Stephen Boyd <sboyd@codeaurora.org>
>> wrote:
>>>
>>> On 10/06/2014 10:28 PM, Guenter Roeck wrote:
>>>>
>>>> Various drivers implement architecture and/or device specific means to
>>>> remove power from the system.  For the most part, those drivers set the
>>>> global variable pm_power_off to point to a function within the driver.
>>>>
>>>> This mechanism has a number of drawbacks.  Typically only one scheme
>>>> to remove power is supported (at least if pm_power_off is used).
>>>> At least in theory there can be multiple means remove power, some of
>>>> which may be less desirable. For example, some mechanisms may only
>>>> power off the CPU or the CPU card, while another may power off the
>>>> entire system.  Others may really just execute a restart sequence
>>>> or drop into the ROM monitor. Using pm_power_off can also be racy
>>>> if the function pointer is set from a driver built as module, as the
>>>> driver may be in the process of being unloaded when pm_power_off is
>>>> called. If there are multiple poweroff handlers in the system, removing
>>>> a module with such a handler may inadvertently reset the pointer to
>>>> pm_power_off to NULL, leaving the system with no means to remove power.
>>>>
>>>> Introduce a system poweroff handler call chain to solve the described
>>>> problems.  This call chain is expected to be executed from the
>>>> architecture specific machine_power_off() function.  Drivers providing
>>>> system poweroff functionality are expected to register with this call
>>>> chain.
>>>> By using the priority field in the notifier block, callers can control
>>>> poweroff handler execution sequence and thus ensure that the poweroff
>>>> handler with the optimal capabilities to remove power for a given system
>>>> is called first.
>>>
>>>
>>> What happened to this series? I want to add shutdown support to my
>>> platform and I need to write a register on the PMIC in one driver to
>>> configure it for shutdown instead of restart and then write an MMIO
>>> register to tell the PMIC to actually do the shutdown in another driver.
>>> It seems that the notifier solves this case for me, albeit with the
>>> slight complication that I need to order the two with some priority.
>>
>>
>> I was wondering the same thing. I did find out that things kind of
>> stalled after Linus cast doubt on the chosen path [1]. I'm not sure
>> there's any consensus on what would be best to do instead.
>>
>
> Linus cast doubt on it, then the maintainers started picking it apart.
> At the end, trying not to use notifier callbacks made the code so
> complicated that even I didn't understand it anymore. With no consensus
> in sight, I abandoned it.
>
> Problem is really that the notifier call chain would be perfect to solve
> the problem, yet Linus didn't like priorities (which are essential),
> and the power maintainers didn't like that a call chain is supposed
> to execute _all_ callbacks, which would not be the case here. If I were
> to start again, I would insist to use notifiers. However, I don't see
> a chance to get that accepted, so I won't. Feel free to pick it up and
> give it a try yourself.

How about having two phases? One where all interested parts of the
system get notified, one that does the final shutdown. It's a slightly
different approach than you took, but does use the notifier chains as
expected, and can be used to prepare peripherals for shutdown, if
there's a use case for it.

The two-stage approach does keep the single place to power down. I
expect it would become more obvious that it would be silly to have
more than one actual system power down sequence and hiding
pm_power_off and unifying setting of it should become more straight
forward as well.

Thoughts?

Thanks,
Frans
