From: Yijing Wang <wangyijing@huawei.com>
Date: Wed, 05 Jun 2013 02:32:24 +0000
Subject: Re: [PATCH -v3 8/8] PCI: Replace printks with appropriate pr_*()
Message-Id: <51AEA338.3090901@huawei.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1370343554-11812-9-git-send-email-wangyijing@huawei.com>
In-Reply-To: <1370343554-11812-9-git-send-email-wangyijing@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>> -               printk(KERN_ERR "PCI: No memory for %s I/O port space\n",
>> +               pr_err("PCI: No memory for %s I/O port space\n",
> 
> Use dev_err() here, since you have the struct acpi_device pointer
> (info->bridge).

Sure, I will update it.

> 
>>                         info->name);
>>                 goto out;
>>         }
>> @@ -444,7 +444,7 @@ struct pci_bus *pci_acpi_scan_root(struct acpi_pci_root *root)
>>
>>         info = kzalloc(sizeof(*info), GFP_KERNEL);
>>         if (!info) {
>> -               printk(KERN_WARNING "pci_bus %04x:%02x: "
>> +               pr_warn("pci_bus %04x:%02x: "
>>                                 "ignored (out of memory)\n", domain, busnum);
> 
> And here.

will update too, thanks!

> 
>>                 kfree(controller);
>>                 return NULL;
>> @@ -779,7 +779,7 @@ static void __init set_pci_dfl_cacheline_size(void)
>>
>>         status = ia64_pal_cache_summary(&levels, &unique_caches);
>>         if (status != 0) {
>> -               printk(KERN_ERR "%s: ia64_pal_cache_summary() failed "
>> +               pr_err("%s: ia64_pal_cache_summary() failed "
>>                         "(status=%ld)\n", __func__, status);
>>                 return;
>>         }
>> @@ -787,7 +787,7 @@ static void __init set_pci_dfl_cacheline_size(void)
>>         status = ia64_pal_cache_config_info(levels - 1,
>>                                 /* cache_type (data_or_unified)= */ 2, &cci);
>>         if (status != 0) {
>> -               printk(KERN_ERR "%s: ia64_pal_cache_config_info() failed "
>> +               pr_err("%s: ia64_pal_cache_config_info() failed "
>>                         "(status=%ld)\n", __func__, status);
>>                 return;
>>         }
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

