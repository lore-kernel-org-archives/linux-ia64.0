From: Hidetoshi Seto <seto.hidetoshi@jp.fujitsu.com>
Date: Fri, 10 Jun 2005 10:31:33 +0000
Subject: Re: [PATCH 00/10] IOCHK interface for I/O error handling/detecting
Message-Id: <42A96C05.4090301@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <42A8386F.2060100@jp.fujitsu.com>	 <20050609171332.GC24611@parcelfarce.linux.theplanet.co.uk> <1118355999.6850.177.camel@gaston>
In-Reply-To: <1118355999.6850.177.camel@gaston>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Cc: Matthew Wilcox <matthew@wil.cx>, Linux Kernel list <linux-kernel@vger.kernel.org>, linux-ia64@vger.kernel.org, Linas Vepstas <linas@austin.ibm.com>, long <tlnguyen@snoqualmie.dp.intel.com>, linux-pci@atrey.karlin.mff.cuni.cz, linuxppc64-dev <linuxppc64-dev@ozlabs.org>

Hi Ben,

Benjamin Herrenschmidt wrote:
>>>- Additionally adds special token - abstract "iocookie" structure
>>>  to control/identifies/manage I/Os, by passing it to OS.
>>>  Actual type of "iocookie" could be arch-specific. Device drivers
>>>  could use the iocookie structure without knowing its detail.
>>
>>I'm not sure we need this.  Surely it can be deduced from the pci_dev or
>>struct device?
> 
> Might be useful to know more though, wether it was PIO or MMIO or other
> things. Also, I'd like to carry around the possible error details as can
> be returned by the firmware in some platforms.
> 
> In fact, Is there any reason this is not ioerr_cookie instead of
> iocookie ? :)

To be honest, No :)
Or is there any reason to limit use of this cookie only for errors?

Thanks,
H.Seto

