From: Hanna Linder <hannal@us.ibm.com>
Date: Mon, 10 Jan 2005 21:18:42 +0000
Subject: Re: [patch 2/3] Replace pci_find_device with pci_get_device
Message-Id: <139420000.1105391922@w-hlinder.beaverton.ibm.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20050110194635.844AE1F203@trashy.coderock.org>
In-Reply-To: <20050110194635.844AE1F203@trashy.coderock.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

--On Monday, January 10, 2005 01:09:30 PM -0800 Jesse Barnes <jbarnes@engr.sgi.com> wrote:

> On Monday, January 10, 2005 11:46 am, domen@coderock.org wrote:
>> -  while ((dev = pci_find_device(PCI_ANY_ID, PCI_ANY_ID, dev)) != NULL)
>> +  while ((dev = pci_get_device(PCI_ANY_ID, PCI_ANY_ID, dev)) != NULL)
>>     acpi_pci_irq_enable(dev);
> 
> Shouldn't this be for_each_pci_dev(dev) acpi_pci_irq_enable(dev); instead?  
> Bjorn?
> 
> Thanks,
> Jesse

Looks to me like it should be as well. I must have missed it when I went through
and did for_each_pci_dev. I can try to make a new patch but it might take a day
or two.

Hanna

