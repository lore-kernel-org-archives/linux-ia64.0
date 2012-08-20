From: Jiang Liu <liuj97@gmail.com>
Date: Mon, 20 Aug 2012 15:43:54 +0000
Subject: Re: [PATCH v1] PCI,IA64: free associated resources when removing host bridges
Message-Id: <50325B3A.9090007@gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1337930622-7696-1-git-send-email-jiang.liu@huawei.com> <CAErSpo4Ya4TXns664jXHqDSLfPGnE-v5GD0fTpjxU7q45WQ02w@mail.gmail.com>
In-Reply-To: <CAErSpo4Ya4TXns664jXHqDSLfPGnE-v5GD0fTpjxU7q45WQ02w@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Bjorn Helgaas <bhelgaas@google.com>
Cc: Jiang Liu <jiang.liu@huawei.com>, Yinghai Lu <yinghai@kernel.org>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Yijing Wang <wangyijing@huawei.com>, Keping Chen <chenkeping@huawei.com>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, linux-pci@vger.kernel.org

On 08/16/2012 04:06 AM, Bjorn Helgaas wrote:
>> ---
>>
>> This patch applies to
>> git://git.kernel.org/pub/scm/linux/kernel/git/helgaas/pci.git pci/next-3.5
> 
> x86 does the exact same thing in arch/x86/pci/acpi.c (some of the data
> structures are slightly different and ia64 does have the extra
> memory-mapped I/O port space regions, but they are essentially
> similar).  Can you rework this a bit so it looks more like the x86
> code, e.g., use the same function names and code when possible?
> 
> Someday the x86 and ia64 code should be converged, and if the code
> looks more similar, that's more likely to happen.
Hi Bjorn,
	My original plan was to follow x86 implementation, but found there's
a race condition with current "pci_set_host_bridge_release()" design. 
	So the IA64 version is implemented in the way to fix the design flaw 
related to pci_set_host_bridge_release(). I will send out another patches to
fix the design flaw and to enhance x86 version to follow IA64.

>> +static void shutdown_pci_controller(struct pci_host_bridge *bridge)
>> +{
>> +       unsigned int i;
>> +       struct resource *resource;
>> +       struct iospace_resource *iospace;
>> +       struct pci_controller *controller = bridge->release_data;
>> +
>> +       if (!controller)
>> +               return;
> 
> I'd remove this test because controller will be NULL only if there's a
> programming error, and having the test here would cover up such
> errors.
Over defensive, will remove it.

	Regards!
	Gerry

