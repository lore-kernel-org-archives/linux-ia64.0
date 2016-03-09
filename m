From: "Rafael J. Wysocki" <rafael@kernel.org>
Date: Wed, 09 Mar 2016 14:20:32 +0000
Subject: Re: [PATCH v2] PCI: ACPI: IA64: fix IO port generic range check
Message-Id: <CAJZ5v0gt9uyLWpr0cedKt-dahCfUdN8Ha4mSeL_bNV2YkMWdZg@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1455212827-9382-1-git-send-email-lorenzo.pieralisi@arm.com>
	<20160308222125.GG27132@localhost>
	<CAJZ5v0gnDnF_4z_mtZp+Tq8-V3FgG6p7kMykqtVA+s44ukkuaA@mail.gmail.com>
	<20160309053332.GA22228@localhost>
	<20160309071406.GA19555@red-moon>
In-Reply-To: <20160309071406.GA19555@red-moon>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Lorenzo Pieralisi <lorenzo.pieralisi@arm.com>
Cc: Bjorn Helgaas <helgaas@kernel.org>, "Rafael J. Wysocki" <rafael@kernel.org>, Linux PCI <linux-pci@vger.kernel.org>, ACPI Devel Maling List <linux-acpi@vger.kernel.org>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, Bjorn Helgaas <bhelgaas@google.com>, Hanjun Guo <hanjun.guo@linaro.org>, Jiang Liu <jiang.liu@linux.intel.com>, Tony Luck <tony.luck@intel.com>, Tomasz Nowicki <tn@semihalf.com>, Mark Salter <msalter@redhat.com>, "Rafael J. Wysocki" <rjw@rjwysocki.net>

On Wed, Mar 9, 2016 at 8:14 AM, Lorenzo Pieralisi
<lorenzo.pieralisi@arm.com> wrote:
> On Tue, Mar 08, 2016 at 11:33:32PM -0600, Bjorn Helgaas wrote:
>> On Tue, Mar 08, 2016 at 11:27:01PM +0100, Rafael J. Wysocki wrote:
>> > On Tue, Mar 8, 2016 at 11:21 PM, Bjorn Helgaas <helgaas@kernel.org> wrote:
>> > > On Thu, Feb 11, 2016 at 05:47:07PM +0000, Lorenzo Pieralisi wrote:
>> > >> The [0 - 64k] ACPI PCI IO port resource boundary check in:
>> > >>

[cut]

>> Wait a minute, this doesn't seem right to me.
>>
>> The problem we're trying to fix is that on ia64, we incorrectly
>> discard the PCI host bridge window [io  0x1000000-0x100ffff window].
>>
>> That window is currently discarded by the generic
>> acpi_dev_ioresource_flags() function, where we're removing this code:
>>
>> -       if (res->end >= 0x10003)
>> -               res->flags |= IORESOURCE_DISABLED | IORESOURCE_UNSET;
>>
>> and we're adding the "res->end >= 0x10003" check to
>> arch/x86/pci/acpi.c.
>>
>> But the removal also affects other users of acpi_dev_ioresource_flags(),
>> and that's broader than the scope of this patch.  We might want to
>> remove the check, but if we do, it should be in a separate patch by
>> itself so it isn't a hidden side-effect of fixing this ia64 problem.
>>
>> The other users of acpi_dev_ioresource_flags() include:
>>
>>     {acpi_lpss_create_device,acpi_create_platform_device,acpi_pci_probe_root_resources,acpi_default_enumeration,bcm_acpi_probe,tpm_tis_acpi_init,acpi_dma_parse_resource_group,acpi_dma_request_slave_chan_by_index,acpi_gpio_resource_lookup,acpi_gpio_count,acpi_i2c_add_device,inv_mpu_process_acpi_config,acpi_spi_add_device}
>>       acpi_dev_get_resources
>>         acpi_dev_process_resource
>>           acpi_dev_resource_io
>>             acpi_dev_get_ioresource
>>               acpi_dev_ioresource_flags
>>
>>     {pnpacpi_add_device,resources_store}
>>       pnpacpi_parse_allocated_resource
>>         pnpacpi_allocated_resource
>>           acpi_dev_resource_io
>>             acpi_dev_get_ioresource
>>               acpi_dev_ioresource_flags
>>
>> I think the original test in acpi_dev_ioresource_flags() isn't quite
>> correct because it's generic code, but it enforces an arch-specific
>> 64K limit.
>
> Yes, I was about to write to you I noticed the same issue.
>
> That (>=0x10003) check in generic code is an x86ism, it is wrong but
> it is there and given that there are other potential
> users of acpi_dev_ioresource_flags() this patch should
> be dropped I do not want to trigger x86 regressions because
> some IO resources are not filtered.
>
> I am travelling, so can't have a proper look till next week,
> Rafael, please drop this patch.
>
>> Maybe acpi_dev_ioresource_flags() should instead check res->end
>> against ioport_resource.end, as we already do in
>> acpi_pci_root_validate_resources()?  Each arch already sets its own
>> ioport_resource.end using IO_SPACE_LIMIT:
>>
>>   arch/x86/include/asm/io.h   #define IO_SPACE_LIMIT 0xffff
>>   arch/ia64/include/asm/io.h  #define IO_SPACE_LIMIT 0xffffffffffffffffUL
>
> We can't do that, it may work on IA64 but the ioport_resource is a
> chunk of address space on IA64/ARM64 that has nothing to do with
> the physical address at which the root bridges decode IO space (which
> is what's contained in the resource).
>
> I will have a look next week, please drop this patch.

OK, dropping.

Thanks,
Rafael
