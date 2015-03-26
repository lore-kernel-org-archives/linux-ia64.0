From: Yijing Wang <wangyijing@huawei.com>
Date: Thu, 26 Mar 2015 01:34:25 +0000
Subject: Re: [PATCH v8 10/30] PCI: Introduce pci_host_bridge_list to manage host bridges
Message-Id: <55136221.1080501@huawei.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1427168064-8657-1-git-send-email-wangyijing@huawei.com> <1427168064-8657-11-git-send-email-wangyijing@huawei.com> <5512E566.5050201@linaro.org>
In-Reply-To: <5512E566.5050201@linaro.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Tomasz Nowicki <tomasz.nowicki@linaro.org>
Cc: Bjorn Helgaas <bhelgaas@google.com>, Liviu Dudau <liviu@dudau.co.uk>, Rusty Russell <rusty@rustcorp.com.au>, Russell King <linux@arm.linux.org.uk>, Arnd Bergmann <arnd@arndb.de>, Marc Zyngier <marc.zyngier@arm.com>, linux-pci@vger.kernel.org, x86@kernel.org, linux-m68k@vger.kernel.org, linux-kernel@vger.kernel.org, "David S. Miller" <davem@davemloft.net>, linux-alpha@vger.kernel.org, Tony Luck <tony.luck@intel.com>, Geert Uytterhoeven <geert@linux-m68k.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, linux-ia64@vger.kernel.org, Thomas Gleixner <tglx@linutronix.de>, Guan Xuetao <gxt@mprc.pku.edu.cn>, Yinghai Lu <yinghai@kernel.org>, Jiang Liu <jiang.liu@linux.intel.com>, linux-arm-kernel@lists.infradead.org

On 2015/3/26 0:42, Tomasz Nowicki wrote:
> On 24.03.2015 04:34, Yijing Wang wrote:
>> Introduce pci_host_bridge_list to manage pci host
>> bridges in system, this make us have the ability
>> to check whether the new host would conflict with
>> existing one. Then we could remove bus alreay exist
>> check in __pci_create_root_bus().
>>
>> Signed-off-by: Yijing Wang <wangyijing@huawei.com>
>> ---
>>   drivers/pci/host-bridge.c |   41 ++++++++++++++++++++++++++++++++++++++++-
>>   drivers/pci/probe.c       |    9 +--------
>>   include/linux/pci.h       |    1 +
>>   3 files changed, 42 insertions(+), 9 deletions(-)
>>
>> diff --git a/drivers/pci/host-bridge.c b/drivers/pci/host-bridge.c
>> index 1a9834b..8af6d51 100644
>> --- a/drivers/pci/host-bridge.c
>> +++ b/drivers/pci/host-bridge.c
>> @@ -8,6 +8,9 @@
>>
>>   #include "pci.h"
>>
>> +static LIST_HEAD(pci_host_bridge_list);
>> +static DEFINE_MUTEX(pci_host_mutex);
>> +
>>   static void pci_release_host_bridge_dev(struct device *dev)
>>   {
>>       struct pci_host_bridge *bridge = to_pci_host_bridge(dev);
>> @@ -41,12 +44,29 @@ static void pci_host_update_busn_res(
>>       pci_add_resource(resources, &host->busn_res);
>>   }
>>
>> +static bool pci_host_busn_res_overlap(
>> +        struct pci_host_bridge *new, struct pci_host_bridge *old)
>> +{
>> +    struct resource_entry *entry;
>> +    struct resource *res1 = NULL, *res2 = NULL;
>> +
>> +    resource_list_for_each_entry(entry, &old->windows)
>> +        if (entry->res->flags & IORESOURCE_BUS)
>> +            res1 = entry->res;
>> +
>> +    resource_list_for_each_entry(entry, &new->windows)
>> +        if (entry->res->flags & IORESOURCE_BUS)
>> +            res2 = entry->res;
>> +
>> +    return resource_overlaps(res1, res2);
>> +}
>> +
>>   struct pci_host_bridge *pci_create_host_bridge(
>>           struct device *parent, int domain, int bus,
>>           struct list_head *resources)
>>   {
>>       int error;
>> -    struct pci_host_bridge *host;
>> +    struct pci_host_bridge *host, *tmp;
>>       struct resource_entry *window, *n;
>>
>>       host = kzalloc(sizeof(*host), GFP_KERNEL);
>> @@ -65,6 +85,21 @@ struct pci_host_bridge *pci_create_host_bridge(
>>        */
>>       host->domain = domain;
>>       pci_host_assign_domain_nr(host);
>> +    mutex_lock(&pci_host_mutex);
>> +    list_for_each_entry(tmp, &pci_host_bridge_list, list) {
>> +        if (tmp->domain != host->domain
>> +              || pci_host_busn_res_overlap(host, tmp)) {
> 
> I think you should construct condition this way:
> +        if (tmp->domain = host->domain
> +              && pci_host_busn_res_overlap(host, tmp)) {

Good catch! I mistook this in the v8. Tomasz, thanks for your review!


> 
> Regards,
> Tomasz
> 
>> +            pr_warn("pci host bridge pci%04x:%02x exist\n",
>> +                    host->domain, bus);
>> +            mutex_unlock(&pci_host_mutex);
>> +            pci_free_resource_list(&host->windows);
>> +            kfree(host);
>> +            return NULL;
>> +        }
>> +    }
>> +    list_add_tail(&host->list, &pci_host_bridge_list);
>> +    mutex_unlock(&pci_host_mutex);
>> +
>>       host->dev.release = pci_release_host_bridge_dev;
>>       dev_set_name(&host->dev, "pci%04x:%02x",
>>               host->domain, bus);
>> @@ -80,6 +115,10 @@ struct pci_host_bridge *pci_create_host_bridge(
>>
>>   void pci_free_host_bridge(struct pci_host_bridge *host)
>>   {
>> +    mutex_lock(&pci_host_mutex);
>> +    list_del(&host->list);
>> +    mutex_unlock(&pci_host_mutex);
>> +
>>       device_unregister(&host->dev);
>>   }
>>
>> diff --git a/drivers/pci/probe.c b/drivers/pci/probe.c
>> index 25ac741..8517d1b 100644
>> --- a/drivers/pci/probe.c
>> +++ b/drivers/pci/probe.c
>> @@ -1869,7 +1869,7 @@ static struct pci_bus *__pci_create_root_bus(
>>           void *sysdata)
>>   {
>>       int error;
>> -    struct pci_bus *b, *b2;
>> +    struct pci_bus *b;
>>       struct resource_entry *window;
>>       struct device *parent;
>>       struct resource *res;
>> @@ -1887,12 +1887,6 @@ static struct pci_bus *__pci_create_root_bus(
>>       b->number = b->busn_res.start >>           pci_host_first_busnr(bridge);
>>       pci_bus_assign_domain_nr(b, parent);
>> -    b2 = pci_find_bus(pci_domain_nr(b), b->number);
>> -    if (b2) {
>> -        /* If we already got to this bus through a different bridge, ignore it */
>> -        dev_dbg(&b2->dev, "bus already known\n");
>> -        goto err_out;
>> -    }
>>
>>       bridge->bus = b;
>>       b->bridge = get_device(&bridge->dev);
>> @@ -1952,7 +1946,6 @@ static struct pci_bus *__pci_create_root_bus(
>>
>>   put_dev:
>>       put_device(&bridge->dev);
>> -err_out:
>>       kfree(b);
>>       return NULL;
>>   }
>> diff --git a/include/linux/pci.h b/include/linux/pci.h
>> index f189dfb..91cba01 100644
>> --- a/include/linux/pci.h
>> +++ b/include/linux/pci.h
>> @@ -407,6 +407,7 @@ struct pci_host_bridge {
>>       /* we use default bus resource if no bus resource provided */
>>       struct resource busn_res;
>>       struct list_head windows;    /* resource_entry */
>> +    struct list_head list;
>>       void (*release_fn)(struct pci_host_bridge *);
>>       void *release_data;
>>   };
>>
> 
> .
> 


-- 
Thanks!
Yijing

