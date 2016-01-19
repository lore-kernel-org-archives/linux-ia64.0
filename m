From: Ganapatrao Kulkarni <gpkulkarni@gmail.com>
Date: Tue, 19 Jan 2016 05:59:49 +0000
Subject: Re: [PATCH v9 5/6] PCI: generic: Make pci-host-generic driver numa aware
Message-Id: <CAFpQJXXESn1EA5kotVOH2oLbRUSpOLf6+MeWG1pY_GhUP+4vVQ@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1453134965-6125-1-git-send-email-gkulkarni@caviumnetworks.com>
	<1453134965-6125-6-git-send-email-gkulkarni@caviumnetworks.com>
	<569D23AF.9050503@gmail.com>
In-Reply-To: <569D23AF.9050503@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: David Daney <ddaney.cavm@gmail.com>, Will Deacon <Will.Deacon@arm.com>, Bjorn Helgaas <bhelgaas@google.com>
Cc: Ganapatrao Kulkarni <gkulkarni@caviumnetworks.com>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, "devicetree@vger.kernel.org" <devicetree@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, linux-pci@vger.kernel.org, linux-ia64@vger.kernel.org, linux-metag@vger.kernel.org, linuxppc-dev <linuxppc-dev@lists.ozlabs.org>, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, linux-arch@vger.kernel.org, Catalin Marinas <catalin.marinas@arm.com>, Grant Likely <grant.likely@linaro.org>, Leif Lindholm <leif.lindholm@linaro.org>, rfranz@cavium.com, Ard Biesheuvel <ard.biesheuvel@linaro.org>, "msalter@redhat.com" <msalter@redhat.com>, Rob Herring <robh+dt@kernel.org>, Steve Capper <steve.capper@linaro.org>, Hanjun Guo <hanjun.guo@linaro.org>, Al Stone <al.stone@linaro.org>, Arnd Bergmann <arnd@arndb.de>, Pawel

On Mon, Jan 18, 2016 at 11:11 PM, David Daney <ddaney.cavm@gmail.com> wrote:
> On 01/18/2016 08:36 AM, Ganapatrao Kulkarni wrote:
>>
>> update numa_node of device associated with pci bus.
>> moved down devm_kzalloc to allocate from node memory.
>>
>> Signed-off-by: Ganapatrao Kulkarni <gkulkarni@caviumnetworks.com>
>> ---
>>   drivers/pci/host/pci-host-generic.c | 9 ++++++---
>>   1 file changed, 6 insertions(+), 3 deletions(-)
>>
>> diff --git a/drivers/pci/host/pci-host-generic.c
>> b/drivers/pci/host/pci-host-generic.c
>> index 5434c90..0e1ce06 100644
>> --- a/drivers/pci/host/pci-host-generic.c
>> +++ b/drivers/pci/host/pci-host-generic.c
>> @@ -215,11 +215,9 @@ static int gen_pci_probe(struct platform_device
>> *pdev)
>>         const struct of_device_id *of_id;
>>         struct device *dev = &pdev->dev;
>>         struct device_node *np = dev->of_node;
>> -       struct gen_pci *pci = devm_kzalloc(dev, sizeof(*pci), GFP_KERNEL);
>> +       struct gen_pci *pci;
>>         struct pci_bus *bus, *child;
>>
>> -       if (!pci)
>> -               return -ENOMEM;
>>
>>         type = of_get_property(np, "device_type", NULL);
>>         if (!type || strcmp(type, "pci")) {
>> @@ -230,6 +228,11 @@ static int gen_pci_probe(struct platform_device
>> *pdev)
>>         of_pci_check_probe_only();
>>
>>         of_id = of_match_node(gen_pci_of_match, np);
>> +       set_dev_node(dev, of_node_to_nid(np));
>
>
> This shouldn't be done in individual platform_drivers, but instead in the
> device probing code.
>
> There is code that does this in drivers/of/platform.c and
> drivers/of/device.c  Is that not being called for the pci-host-gweneric
> devices?  If not, we should figure out why, and perhaps attempt to fix it
> rather than doing it here.
is it more appropriate to call of_platform_device_create ?

--- a/drivers/pci/host/pci-host-generic.c
+++ b/drivers/pci/host/pci-host-generic.c
@@ -24,6 +24,7 @@
 #include <linux/of_address.h>
 #include <linux/of_pci.h>
 #include <linux/platform_device.h>
+#include <linux/of_platform.h>

 struct gen_pci;

@@ -466,7 +467,7 @@ static int gen_pci_probe(struct platform_device *pdev)
        of_pci_check_probe_only();

        of_id = of_match_node(gen_pci_of_match, np);
-       set_dev_node(dev, of_node_to_nid(np));
+       of_platform_device_create(np, NULL, NULL);
        pci = devm_kzalloc(dev, sizeof(*pci), GFP_KERNEL);
        if (!pci)
                return -ENOMEM;

>
>
>
>> +       pci = devm_kzalloc(dev, sizeof(*pci), GFP_KERNEL);
>> +       if (!pci)
>> +               return -ENOMEM;
>> +
>>         pci->cfg.ops = (struct gen_pci_cfg_bus_ops *)of_id->data;
>>         pci->host.dev.parent = dev;
>>         INIT_LIST_HEAD(&pci->host.windows);
>>
>
thanks
Ganapat
