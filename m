From: Lan Tianyu <tianyu.lan@intel.com>
Date: Fri, 18 Oct 2013 12:44:12 +0000
Subject: Re: [Resend PATCH 5/5] IA64/PCI/ACPI: Rework PCI root bridge ACPI resource conversion
Message-Id: <52612D1C.4070701@intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1381493941-4650-1-git-send-email-tianyu.lan@intel.com> <1381493941-4650-6-git-send-email-tianyu.lan@intel.com> <20131016235541.GD17866@google.com> <525F7F0F.5010306@intel.com> <CAErSpo7P+n5c2uUoodT=LOjE3UH3LBcjifbj8reXzAeWydsoLA@mail.gmail.com>
In-Reply-To: <CAErSpo7P+n5c2uUoodT=LOjE3UH3LBcjifbj8reXzAeWydsoLA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
To: Bjorn Helgaas <bhelgaas@google.com>
Cc: Tony Luck <tony.luck@intel.com>, Len Brown <lenb@kernel.org>, "Rafael J. Wysocki" <rjw@sisk.pl>, Yinghai Lu <yinghai@kernel.org>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-acpi@vger.kernel.org" <linux-acpi@vger.kernel.org>, "Yoknis, Mike" <mike.yoknis@hp.com>

On 10/18/2013 04:33 AM, Bjorn Helgaas wrote:
> [+cc Mike]
>
> On Thu, Oct 17, 2013 at 12:09 AM, Lan Tianyu <tianyu.lan@intel.com>
> wrote:
>> On 2013年10月17日 07:55, Bjorn Helgaas wrote:
>>> On Fri, Oct 11, 2013 at 08:19:01PM +0800, tianyu.lan@intel.com
>>> wrote:
>>>> From: Lan Tianyu <tianyu.lan@intel.com>
>>>>
>>>> Using ACPI resource functions to convert ACPI resource to
>>>> generic resource
>>>>
>>>> Signed-off-by: Lan Tianyu <tianyu.lan@intel.com> --- This patch
>>>> just passes through compilation test due to no ia64 machine on
>>>> hand.
>>>>
>>>> arch/ia64/pci/pci.c | 38
>>>> +++++++++++++++++++++----------------- 1 file changed, 21
>>>> insertions(+), 17 deletions(-)
>>>>
>>>> diff --git a/arch/ia64/pci/pci.c b/arch/ia64/pci/pci.c index
>>>> 2326790..14fa175 100644 --- a/arch/ia64/pci/pci.c +++
>>>> b/arch/ia64/pci/pci.c @@ -232,8 +232,9 @@ out: return ~0; }
>>>>
>>>> -static acpi_status resource_to_window(struct acpi_resource
>>>> *resource, -                                  struct
>>>> acpi_resource_address64 *addr) +static acpi_status
>>>> resource_to_window(struct acpi_resource *ares, +
>>>> struct acpi_resource_address64 *addr, +
>>>> struct resource *res) { acpi_status status;
>>>>
>>>> @@ -244,7 +245,7 @@ static acpi_status
>>>> resource_to_window(struct acpi_resource *resource, *      -
>>>> producers, i.e., the address space is routed downstream, *
>>>> not consumed by the bridge itself */ -    status >>>> acpi_resource_to_address64(resource, addr); +    status >>>> acpi_dev_resource_address_space_full(ares, addr, res); if
>>>> (ACPI_SUCCESS(status) && (addr->resource_type =
>>>> ACPI_MEMORY_RANGE || addr->resource_type = ACPI_IO_RANGE) &&
>>>> @@ -255,51 +256,54 @@ static acpi_status
>>>> resource_to_window(struct acpi_resource *resource, return
>>>> AE_ERROR; }
>>>>
>>>> -static acpi_status count_window(struct acpi_resource
>>>> *resource, void *data) +static acpi_status count_window(struct
>>>> acpi_resource *ares, void *data) { unsigned int *windows >>>> (unsigned int *) data; struct acpi_resource_address64 addr; +
>>>> struct resource res; acpi_status status;
>>>>
>>>> -    status = resource_to_window(resource, &addr); +    status
>>>> = resource_to_window(ares, &addr, &res); if
>>>> (ACPI_SUCCESS(status)) (*windows)++;
>>>>
>>>> return AE_OK; }
>>>>
>>>> -static acpi_status add_window(struct acpi_resource *res, void
>>>> *data) +static acpi_status add_window(struct acpi_resource
>>>> *ares, void *data) { struct pci_root_info *info = data; -
>>>> struct resource *resource; +    struct resource *resource >>>> &info->res[info->res_num]; struct acpi_resource_address64
>>>> addr; acpi_status status; -    unsigned long flags, offset >>>> 0; +    unsigned long offset = 0; struct resource *root;
>>>>
>>>> /* Return AE_OK for non-window resources to keep scanning for
>>>> more */ -    status = resource_to_window(res, &addr); +
>>>> status = resource_to_window(ares, &addr, resource); if
>>>> (!ACPI_SUCCESS(status)) return AE_OK;
>>>>
>>>> -    if (addr.resource_type = ACPI_MEMORY_RANGE) { -
>>>> flags = IORESOURCE_MEM; +    if (resource->flags &
>>>> IORESOURCE_MEM) { root = &iomem_resource; offset >>>> addr.translation_offset; -    } else if (addr.resource_type =
>>>> ACPI_IO_RANGE) { -            flags = IORESOURCE_IO; +    }
>>>> else if (resource->flags & IORESOURCE_IO) { root >>>> &ioport_resource; offset = add_io_space(info, &addr); if
>>>> (offset = ~0) return AE_OK; + +            /* +             *
>>>> io space address translation offset depends +             * on
>>>> the return value of add_io_space(). So +             *
>>>> Repopulate resource->start and end here.
>>>
>>> "Repopulate" makes it sound like "resource->start" got clobbered
>>> somewhere.  But it didn't.  I think it's just that each bridge
>>> can support its own I/O port range, and the PCI port numbers
>>> reported in the acpi_resource may not be distinct, and
>>> add_io_space() adds an offset so all the I/O port ranges fit into
>>> one global I/O port space.
>>>
>>> For example, I think these two bridges have the same port
>>> numbers (0x0-0xfff) in their acpi_resource, but the second has an
>>> offset of 0x1000000 in the system I/O port space, and I think
>>> this offset is what add_io_space() returns:
>>>
>>> HWP0002:00: host bridge window [io  0x0000-0x0fff]     (PCI
>>> [0x0-0xfff]) HWP0002:09: host bridge window [io
>>> 0x1000000-0x1000fff] (PCI [0x0-0xfff])
>>>
>>>> +             */ +            resource->start = addr.minimum +
>>>> offset; +            resource->end = resource->start +
>>>> addr.address_length - 1;
>>>
>>> Can't we use this:
>>>
>>> resource->start += offset; resource->end += offset;
>>>
>>> to avoid breaking the encapsulation of struct
>>> acpi_resource_address64?
>>
>> resource->start has been populated with "addr.minimum +
>> addr.translation_offset" in the acpi_dev_resource_address_space().
>
> That's true, but this is a change from previous behavior.
> Previously, x86 applied addr.translation_offset to both MEM and IO
> resources (in setup_resource()), but ia64 applied it only to MEM
> resources (in add_window()).  With your patch, we apply it to both
> types in acpi_dev_resource_address_space(), which is a change for
> ia64.

Yes, this is why I repopulate resource->start and ->end after
add_io_space().

>
> I know translation_offset is used on some HP ia64 boxes, but I'm not
> aware of it being used for IO resources on any x86 boxes.  On those
> ia64 boxes, the bridge also does type translation (the resource is
> MEM on the primary side but IO on the secondary side).  In that case,
> I'm not sure it makes sense to add the translation_offset to an IO
> address and expect the result to be a MEM address.
>
> On these HP ia64 boxes, the firmware puts the CPU physical address
> of the MEM resource in the translation_offset (see the call to
> new_space()).  The bridge then translates that MEM resource to IO on
> the secondary side.  It's awfully hard for me to extract this usage
> from the ACPI spec, so possibly this is just a quirk of the way HP
> encoded these IO resources.  But it *is* a precedent, and I'm not
> aware of anybody doing anything that conflicts with it.
>

Thanks for sharing and let me know some background about this. Honestly,
I just change the code just according to the original. It's good to have
a chance to see such kind of machine's acpidump.

> I wonder if it would make sense to make
> acpi_dev_resource_address_space() ignore addr.translation_offset for
> IO resources.  Or maybe ignore it if the _TTP (type translation) bit
> is set?

I wonder why current code doesn't check _TTP? The code in the
add_io_space() seems to think _TTP is always set, right?

>
> I think the main intent of translation_offset (_TRA) is to map a
> smaller address space into part of a larger space of the same type,
> e.g., a 32-bit PCI memory space into a 40+ bit CPU memory space.
> That doesn't apply directly to IO ports, because I don't think any
> CPU has a native IO port address space larger than 16 bits, so
> there's no extra space to map into.
>
> Mike, is there any chance you could collect an acpidump from an
> rx7620 or similar ia64 system?  In particular, I want to see a
> multi-node system where we have several PCI domains, and whether it
> sets the _TTP bits.
>
>> continuing to add the offset to resource->start seems not right.
>>
>> The add_io_space() accepts translation_offset and then ioremap it
>> to mmio address. Add the result to io_space array and assign a
>> space number. Left shift the space number 24 bits as the return
>> offset of add_io_space().
>>
>> When one io port address is accessed, __ia64_mk_io_addr() will do
>> reverse operations and find associated mmio address.
>
> Yep, got it.  I wrote all that code originally :)  Obviously it
> hasn't turned out to be particularly easy to understand.
>
> Bjorn
>

