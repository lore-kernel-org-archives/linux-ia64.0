From: Hidetoshi Seto <seto.hidetoshi@jp.fujitsu.com>
Date: Fri, 10 Jun 2005 10:30:24 +0000
Subject: Re: [PATCH 00/10] IOCHK interface for I/O error handling/detecting
Message-Id: <42A96BC0.9000505@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <42A8386F.2060100@jp.fujitsu.com> <20050609171332.GC24611@parcelfarce.linux.theplanet.co.uk>
In-Reply-To: <20050609171332.GC24611@parcelfarce.linux.theplanet.co.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Matthew Wilcox <matthew@wil.cx>
Cc: Linux Kernel list <linux-kernel@vger.kernel.org>, linux-ia64@vger.kernel.org, Linas Vepstas <linas@austin.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, long <tlnguyen@snoqualmie.dp.intel.com>, linux-pci@atrey.karlin.mff.cuni.cz, linuxppc64-dev <linuxppc64-dev@ozlabs.org>

Matthew Wilcox wrote:
>>Today's patch is 3rd one - iochk_clear/read() interface.
>>- This also adds pair-interface, but not to sandwich only readX().
>>  Depends on platform, starting with ioreadX(), inX(), writeX()
>>  if possible... and so on could be target of error checking.
> 
> It makes sense to sandwich other kinds of device accesses.  I don't
> think the previous clear/read_pci_errors() interface was intended *only*
> to sandwich readX().

At least there was _me_ who actually intended that... :-p
Thank you for being so understanding.

>>- Additionally adds special token - abstract "iocookie" structure
>>  to control/identifies/manage I/Os, by passing it to OS.
>>  Actual type of "iocookie" could be arch-specific. Device drivers
>>  could use the iocookie structure without knowing its detail.
> 
> I'm not sure we need this.  Surely it can be deduced from the pci_dev or
> struct device?

Once I prepared a cookie per a device, added it into pci_dev.
But one of our NIC driver folks pointed out that it was hard to handle
because there could be many contexts/threads riding on one device at same
time. So I reconsidered it and now come to "a cookie per a context" style.

>>            *buf++ = ioread32(dev, ofs);
> 
> You do know that ioread32() doesn't take a pci_dev, right?  I hope you
> weren't counting on that for the rest of your implementation.

Oops. It's just my typo. Please ignore it.

Thanks,
H.Seto

