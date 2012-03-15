From: Jiang Liu <jiang.liu@huawei.com>
Date: Thu, 15 Mar 2012 02:19:39 +0000
Subject: Re: [PATCH] IA64: fix ISA IRQ trigger model and polarity setting
Message-Id: <4F6151BB.9000807@huawei.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1331647629-11550-1-git-send-email-jiang.liu@huawei.com>
 <CA+8MBbLsA8OysJNFMN4a0p6Yj3qmmawvtE0pGtcnAJpULjNi+A@mail.gmail.com>
In-Reply-To: <CA+8MBbLsA8OysJNFMN4a0p6Yj3qmmawvtE0pGtcnAJpULjNi+A@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Tony Luck <tony.luck@gmail.com>
Cc: Jiang Liu <liuj97@gmail.com>, linux-ia64@vger.kernel.org, open list <linux-kernel@vger.kernel.org>, chenkeping@huawei.com

Hi Tony,
I have checked the ACPI and MPSpec too. As you have mentioned,
those specifications have no detailed definition for default
trigger mode and polarity setting, only give some examples and
state "refer to the bus specification".

On the other hand, our platform uses Intel Boxboro and ICH10
chipsets, which are the same chipsets used by Intel Emarald-Ridge
platform. The ICH10 has a PCI-ISA bridge, so I assume it's an ISA
bus instead of EISA. Then I referred to x86 IOAPIC implementation
and found that default ISA IRQ trigger/polarity setting is
edge-rising on x86, but level-low on IA64.

As the MPSpec 1.4 table 4-10 states,
EL 2:2 2 Trigger mode of APIC I/O input signals:
	00 = Conforms to specifications of bus (for example, ISA is
	     edge triggered)
	01 = Edge-triggered
	10 = Reserved
	11 = Level-triggered

So at lease IA64 has incorrectly set the default trigger mode to
level-triggered, which violates the specifications.

The scenario to trigger the issue on our platform is as below:
1) System has plenty of IO cards, vector allocation mode is set to
"global" by default. Because the system has limited interrupt vectors,
it begins to sharing interrupt when running out of vectors. With
current implementation, it will share interrupt vector among PCI
IRQs(level-low) and ISA IRQs with default setting, then interrupt
storm happens.
2) If we switch the vector allocation mode to "percpu", system will
have plenty of interrupt vectors, so no interrupt sharing and no 
interrupt storm.

So I think IA64 may have incorrectly set the default trigger/polarity
mode. But I'm not sure whether it will cause any compatibility issues
with existing platforms.

Thanks!

On 2012-3-15 5:12, Tony Luck wrote:
>> When handling Interrupt Source Override in MADT table, the default
>> ISA IRQ trigger model and poliarity should be edge-rising.
>> Current IA64 implmentation doesn't follow the specification and
>> set default ISA IRQ trigger model as level-low. With that wrong
>> configuration and when system runs out of interrupt vectors,
>> it will cause vector sharing among edge triggered ISA IRQ and
>> level triggered PCI IRQ, then interrupt storm. So change the code
>> to follow the specification.
>
> I chased the reference in ACPI to the MPS spec:
>   http://www.intel.com/design/pentium/datashts/24201606.pdf
>
> Which says in table 4-10 "for example. EISA is active-low for
> level triggered interrupt" and "for example, EISA is edge-triggered".
>
> It looks to me that if MADT says "high", we should set high, if it says
> "low" we should set low. Ditto for trigger vs. level. But if we see the
> value "0" - then we have more work to do to determine what the
> bus we are on uses for its default.
>
> Did you find some other specification that gives a better explanation?
> Or did I miss something - can we only get to this routine for ISA?
>
> You've tested this patch - and it works for you - but is there a risk
> that it will break someone else?
>
> -Tony
>
>


