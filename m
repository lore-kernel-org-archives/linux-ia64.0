From: Yijing Wang <wangyijing@huawei.com>
Date: Mon, 29 Sep 2014 10:12:26 +0000
Subject: Re: [PATCH v2 00/22] Use MSI chip framework to configure MSI/MSI-X in all platforms
Message-Id: <5429308A.7030201@huawei.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1411614872-4009-1-git-send-email-wangyijing@huawei.com> <20140925074235.GN12423@ulmo> <20140925144855.GB31157@bart.dudau.co.uk> <20140925164937.GB30382@ulmo> <5424E09F.50701@huawei.com> <20140926085030.GE31157@bart.dudau.co.uk> <54276F6C.5010705@huawei.com> <20140928112144.GA4671@bart.dudau.co.uk> <5428B971.50101@huawei.com> <20140929092600.GA15854@bart.dudau.co.uk>
In-Reply-To: <20140929092600.GA15854@bart.dudau.co.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Liviu Dudau <liviu@dudau.co.uk>
Cc: Thierry Reding <thierry.reding@gmail.com>, Bjorn Helgaas <bhelgaas@google.com>, linux-pci@vger.kernel.org, linux-kernel@vger.kernel.org, Xinwei Hu <huxinwei@huawei.com>, Wuyun <wuyun.wu@huawei.com>, linux-arm-kernel@lists.infradead.org, Russell King <linux@arm.linux.org.uk>, linux-arch@vger.kernel.org, arnab.basu@freescale.com, Bharat.Bhushan@freescale.com, x86@kernel.org, Arnd Bergmann <arnd@arndb.de>, Thomas Gleixner <tglx@linutronix.de>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, xen-devel@lists.xenproject.org, Joerg Roedel <joro@8bytes.org>, iommu@lists.linux-foundation.org, linux-mips@linux-mips.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, Sebastian Ott <sebott@linux.vnet.ibm.com>, Tony Luck <tony.luck@intel.com>, linux-ia64@vger.kernel.org, "David S. Miller" <davem@davemloft.net>, sparclinux@vger.kernel.org, Chris Metcalf <cmetcalf@tilera.com>, Ralf Baechle <ralf@linux-mips.org>, Lucas Stach <l.stach@pengutronix.de>, David Vrabel <david.vrabel@citrix.com>, Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>, Michael Ellerman <mpe@ellerman.id.au>, Thomas Petazzoni <thomas.petazzoni@free-electrons.com>

>>> Not necessarily. What I have in mind is something like this:
>>
>> This is a good idea, what I'm worried is this series is already large, so I think we need to post
>> another series to do it.
> 
> I wasn't asking to do it here, I was just offering a suggestion (and sharing some experience) when
> it comes to handling msi chip in an arch independent way.

It's a good suggestion, thanks! :)

> 
>>
>>

