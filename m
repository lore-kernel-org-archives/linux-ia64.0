From: Yijing Wang <wangyijing@huawei.com>
Date: Wed, 05 Jun 2013 02:31:28 +0000
Subject: Re: [PATCH -v3 2/8] PCI/IA64: SN: use normal resource instead of pci_window
Message-Id: <51AEA300.70408@huawei.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1370343554-11812-3-git-send-email-wangyijing@huawei.com>
In-Reply-To: <1370343554-11812-3-git-send-email-wangyijing@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi Bjorn,
   Thanks for your review and comments very much!

On 2013/6/5 7:03, Bjorn Helgaas wrote:
> It probably wouldn't hurt to cc some SGI folks.

OK, because I cannot get SGI folks by scripts/get_maintainer.pl, I will try
to add cc some SGI folks from git log history.

> 
> On Tue, Jun 4, 2013 at 4:59 AM, Yijing Wang <wangyijing@huawei.com> wrote:
>> Pci_window in pci_controller will not be used again,
>> use normal resource instead of pci_window in
>>                                              GFP_KERNEL);
> 
> This looks totally bogus.  You kcalloc() "res", but you never save the
> pointer anywhere.

I'm very sorry so much. That's totally my fault. I will fix this right now.

Thanks!

> 
>> -               BUG_ON(controller->window = NULL);
>> -               controller->window[0].offset = legacy_io;
>> -               controller->window[0].resource.name = "legacy_io";
>> -               controller->window[0].resource.flags = IORESOURCE_IO;
>> -               controller->window[0].resource.start = legacy_io;
>> -               controller->window[0].resource.end >> -                               controller->window[0].resource.start + 0xffff;
>> -               controller->window[0].resource.parent = &ioport_resource;
>> -               controller->window[1].offset = legacy_mem;
>> -               controller->window[1].resource.name = "legacy_mem";
>> -               controller->window[1].resource.flags = IORESOURCE_MEM;
>> -               controller->window[1].resource.start = legacy_mem;
>> -               controller->window[1].resource.end >> -                      controller->window[1].resource.start + (1024 * 1024) - 1;
>> -               controller->window[1].resource.parent = &iomem_resource;
>> -               controller->windows = 2;
>> +               BUG_ON(res = NULL);
>> +               res[0].name = "legacy_io";
>> +               res[0].flags = IORESOURCE_IO;
>> +               res[0].start = legacy_io;
>> +               res[0].end = res->start + 0xffff;
> 
> I think you meant "res[0].start + 0xffff" here.

Yes, it's my negligence, sorry.

> 
>> +               res[0].parent = &ioport_resource;
>> +               res[1].name = "legacy_mem";
>> +               res[1].flags = IORESOURCE_MEM;
>> +               res[1].start = legacy_mem;
>> +               res[1].end = res->start + (1024 * 1024) - 1;
> 
> And "res[1].start + (1024 * 1024) - 1" here.

sorry, will update it.

> 
>> +               res[1].parent = &iomem_resource;
>>  }
>>
>>  /*
>> @@ -244,8 +239,8 @@ sn_pci_controller_fixup(int segment, int busnum, struct pci_bus *bus)
>>         s64 status = 0;
>>         struct pci_controller *controller;
>>         struct pcibus_bussoft *prom_bussoft_ptr;
>> +       struct resource *res = NULL;
>>         LIST_HEAD(resources);
>> -       int i;
>>
>>         status = sal_get_pcibus_info((u64) segment, (u64) busnum,
>>                                      (u64) ia64_tpa(&prom_bussoft_ptr));
>> @@ -263,13 +258,14 @@ sn_pci_controller_fixup(int segment, int busnum, struct pci_bus *bus)
>>          */
>>         controller->platform_data = prom_bussoft_ptr;
>>
>> -       sn_legacy_pci_window_fixup(controller,
>> -                                  prom_bussoft_ptr->bs_legacy_io,
>> -                                  prom_bussoft_ptr->bs_legacy_mem);
>> -       for (i = 0; i < controller->windows; i++)
>> -               pci_add_resource_offset(&resources,
>> -                                       &controller->window[i].resource,
>> -                                       controller->window[i].offset);
>> +       sn_legacy_pci_window_fixup(res,
>> +                       prom_bussoft_ptr->bs_legacy_io,
>> +                       prom_bussoft_ptr->bs_legacy_mem);
>> +       pci_add_resource_offset(&resources,     &res[0],
>> +                       prom_bussoft_ptr->bs_legacy_io);
>> +       pci_add_resource_offset(&resources,     &res[1],
>> +                       prom_bussoft_ptr->bs_legacy_mem);
>> +
>>         bus = pci_scan_root_bus(NULL, busnum, &pci_root_ops, controller,
>>                                 &resources);
>>         if (bus = NULL)
>> @@ -280,7 +276,7 @@ sn_pci_controller_fixup(int segment, int busnum, struct pci_bus *bus)
>>         return;
>>
>>  error_return:
>> -
>> +       kfree(res);
>>         kfree(controller);
>>         return;
>>  }
>> --
>> 1.7.1
>>
>>
> 
> .
> 


-- 
Thanks!
Yijing

