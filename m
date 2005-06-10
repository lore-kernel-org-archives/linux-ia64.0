From: Hidetoshi Seto <seto.hidetoshi@jp.fujitsu.com>
Date: Fri, 10 Jun 2005 10:31:21 +0000
Subject: Re: [PATCH 03/10] IOCHK interface for I/O error handling/detecting
Message-Id: <42A96BF9.2050608@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <42A8386F.2060100@jp.fujitsu.com> <42A83B6D.8010703@jp.fujitsu.com> <20050609172035.GD24611@parcelfarce.linux.theplanet.co.uk>
In-Reply-To: <20050609172035.GD24611@parcelfarce.linux.theplanet.co.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Matthew Wilcox <matthew@wil.cx>
Cc: Linux Kernel list <linux-kernel@vger.kernel.org>, linux-ia64@vger.kernel.org, Linas Vepstas <linas@austin.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, long <tlnguyen@snoqualmie.dp.intel.com>, linux-pci@atrey.karlin.mff.cuni.cz, linuxppc64-dev <linuxppc64-dev@ozlabs.org>

Matthew Wilcox wrote:
> On Thu, Jun 09, 2005 at 09:51:57PM +0900, Hidetoshi Seto wrote:
> 
>>+	switch (dev->hdr_type) {
>>+	case PCI_HEADER_TYPE_NORMAL: /* 0 */
>>+		pci_read_config_word(dev, PCI_STATUS, &status);
>>+		break;
>>+	case PCI_HEADER_TYPE_BRIDGE: /* 1 */
>>+		pci_read_config_word(dev, PCI_SEC_STATUS, &status);
>>+		break;
>>+	case PCI_HEADER_TYPE_CARDBUS: /* 2 */
>>+	default:
>>+		BUG();
> 
> If somebody plugs a cardbus card into an ia64 machine, we BUG()?
> Unacceptable.  Just return 0 if you don't know what to do with a
> particular device.

Sure, you are right. I'll fix it.

Thanks,
H.Seto

