From: Hanna Linder <hannal@us.ibm.com>
Date: Mon, 10 Jan 2005 21:37:24 +0000
Subject: Re: [patch 2/3] Replace pci_find_device with pci_get_device
Message-Id: <164560000.1105393044@w-hlinder.beaverton.ibm.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20050110194635.844AE1F203@trashy.coderock.org>
In-Reply-To: <20050110194635.844AE1F203@trashy.coderock.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

--On Monday, January 10, 2005 02:21:56 PM -0700 Bjorn Helgaas <bjorn.helgaas@hp.com> wrote:

>> Shouldn't this be for_each_pci_dev(dev) acpi_pci_irq_enable(dev); instead?  
>> Bjorn?
> 
> They're equivalent, right?  Looks OK to me either way.  I guess
> if you switch to for_each_pci_dev(), you could switch the one
> in sba_iommu.c, too.

Yes they are equivalent. Will do.

Hanna



