From: Roland Dreier <rdreier@cisco.com>
Date: Fri, 17 Feb 2006 20:21:37 +0000
Subject: Re: Problems with MSI-X on ia64
Message-Id: <aday809d9da.fsf@cisco.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <B8E391BBE9FE384DAA4C5C003888BE6F05BF610F@scsmsx401.amr.corp.intel.com>
	<20060217200454.GA24942@esmail.cup.hp.com>
In-Reply-To: <20060217200454.GA24942@esmail.cup.hp.com> (Grant Grundler's
 message of "Fri, 17 Feb 2006 12:04:54 -0800")
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Grant Grundler <iod00d@hp.com>
Cc: "Luck, Tony" <tony.luck@intel.com>, Chris Wedgwood <cw@f00f.org>, Grant Grundler <grundler@parisc-linux.org>, Greg KH <gregkh@suse.de>, linux-kernel@vger.kernel.org, linux-scsi@vger.kernel.org, linux-ia64@vger.kernel.org, linux-pci@atrey.karlin.mff.cuni.cz, "Miller, Mike (OS Dev)" <Mike.Miller@hp.com>, Jesse Barnes <jbarnes@virtuousgeek.org>

BARs above 4G on i386 raise all sorts of issues.  I think Grant's
original patch (which changes phys_addr in drivers/pci/msi.c to
unsigned long) is correct as it stands, because the MSI code is going
to use that address to ioremap() the MSI-X table.  And the address
passed to ioremap is unsigned long anyway.

Some extension like ioremap_pfn() or something like that is going to
needed to handling giving the kernel access to BARs above 4G on 32-bit
archs.

 - R.
