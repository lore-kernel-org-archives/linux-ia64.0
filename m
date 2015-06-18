From: Guenter Roeck <linux@roeck-us.net>
Date: Thu, 18 Jun 2015 11:54:03 +0000
Subject: Re: [PATCH 01/44] kernel: Add support for poweroff handler call chain
Message-Id: <5582B15B.4010205@roeck-us.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <1412659726-29957-1-git-send-email-linux@roeck-us.net>	<1412659726-29957-2-git-send-email-linux@roeck-us.net>	<55821936.4040704@codeaurora.org> <CAH6sp9P7rq2y_hiQPHKUP85CwnEmp87yC7Psh4=29h-pYnb_yw@mail.gmail.com>
In-Reply-To: <CAH6sp9P7rq2y_hiQPHKUP85CwnEmp87yC7Psh4=29h-pYnb_yw-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Frans Klaver <fransklaver-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Stephen Boyd <sboyd-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>
Cc: "linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, linux-m32r-ja-rQhvJZKUsGBRYuoOT4C5/9i2O/JbrIOy@public.gmane.org, linux-mips-6z/3iImG2C8G8FEW9MqTrA@public.gmane.org, linux-efi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-ia64-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Heiko Stuebner <heiko-4mtYJXux2i+zQB+pC5nmwQ@public.gmane.org>, linux-sh-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, "devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Pavel Machek <pavel-+ZI9xUNit7I@public.gmane.org>, devel-gWbeCf7V1WCQmaza687I9mD2FQJk+8+b@public.gmane.org, linux-s390-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, lguest-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org, linux-c6x-dev-jPsnJVOj+W6hPH1hqNUYSQ@public.gmane.org, linux-hexagon-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Alexander Graf <agraf-l3A5Bk7waGM@public.gmane.org>, linux-acpi <linux-acpi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Geert Uytterhoeven <geert-Td1EMuHUCqxL1ZNQvxDV9g@public.gmane.org>, xen-devel-GuqFBffKawtpuQazS67q72D2FQJk+8+b@public.gmane.org, Len Brown <len.brown-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>, user-mode-linux-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org, "linux-pm-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-pm-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, linux-xtensa-PjhNF2WwrV/0Sa2dR60CXw@public.gmane.org, adi-buildroot-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org, linux-m68k-cunTk1MwBs8S/qaLPR03pWD2FQJk+8+b@public.gmane.org, linux-am33-list-H+wXaHxf7aJhl2p70BpVqQ@public.gmane.org

On 06/17/2015 11:53 PM, Frans Klaver wrote:
> On Thu, Jun 18, 2015 at 3:04 AM, Stephen Boyd <sboyd@codeaurora.org> wrote:
>> On 10/06/2014 10:28 PM, Guenter Roeck wrote:
>>> Various drivers implement architecture and/or device specific means to
>>> remove power from the system.  For the most part, those drivers set the
>>> global variable pm_power_off to point to a function within the driver.
>>>
>>> This mechanism has a number of drawbacks.  Typically only one scheme
>>> to remove power is supported (at least if pm_power_off is used).
>>> At least in theory there can be multiple means remove power, some of
>>> which may be less desirable. For example, some mechanisms may only
>>> power off the CPU or the CPU card, while another may power off the
>>> entire system.  Others may really just execute a restart sequence
>>> or drop into the ROM monitor. Using pm_power_off can also be racy
>>> if the function pointer is set from a driver built as module, as the
>>> driver may be in the process of being unloaded when pm_power_off is
>>> called. If there are multiple poweroff handlers in the system, removing
>>> a module with such a handler may inadvertently reset the pointer to
>>> pm_power_off to NULL, leaving the system with no means to remove power.
>>>
>>> Introduce a system poweroff handler call chain to solve the described
>>> problems.  This call chain is expected to be executed from the
>>> architecture specific machine_power_off() function.  Drivers providing
>>> system poweroff functionality are expected to register with this call chain.
>>> By using the priority field in the notifier block, callers can control
>>> poweroff handler execution sequence and thus ensure that the poweroff
>>> handler with the optimal capabilities to remove power for a given system
>>> is called first.
>>
>> What happened to this series? I want to add shutdown support to my
>> platform and I need to write a register on the PMIC in one driver to
>> configure it for shutdown instead of restart and then write an MMIO
>> register to tell the PMIC to actually do the shutdown in another driver.
>> It seems that the notifier solves this case for me, albeit with the
>> slight complication that I need to order the two with some priority.
>
> I was wondering the same thing. I did find out that things kind of
> stalled after Linus cast doubt on the chosen path [1]. I'm not sure
> there's any consensus on what would be best to do instead.
>

Linus cast doubt on it, then the maintainers started picking it apart.
At the end, trying not to use notifier callbacks made the code so
complicated that even I didn't understand it anymore. With no consensus
in sight, I abandoned it.

Problem is really that the notifier call chain would be perfect to solve
the problem, yet Linus didn't like priorities (which are essential),
and the power maintainers didn't like that a call chain is supposed
to execute _all_ callbacks, which would not be the case here. If I were
to start again, I would insist to use notifiers. However, I don't see
a chance to get that accepted, so I won't. Feel free to pick it up and
give it a try yourself.

Thanks,
Guenter

