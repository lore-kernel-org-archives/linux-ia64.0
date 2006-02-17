From: Grant Grundler <iod00d@hp.com>
Date: Fri, 17 Feb 2006 20:04:54 +0000
Subject: Re: Problems with MSI-X on ia64
Message-Id: <20060217200454.GA24942@esmail.cup.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <B8E391BBE9FE384DAA4C5C003888BE6F05BF610F@scsmsx401.amr.corp.intel.com>
In-Reply-To: <B8E391BBE9FE384DAA4C5C003888BE6F05BF610F@scsmsx401.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Luck, Tony" <tony.luck@intel.com>
Cc: Chris Wedgwood <cw@f00f.org>, Grant Grundler <grundler@parisc-linux.org>, Greg KH <gregkh@suse.de>, linux-kernel@vger.kernel.org, linux-scsi@vger.kernel.org, linux-ia64@vger.kernel.org, linux-pci@atrey.karlin.mff.cuni.cz, "Miller, Mike (OS Dev)" <Mike.Miller@hp.com>, Jesse Barnes <jbarnes@virtuousgeek.org>

On Fri, Feb 17, 2006 at 11:52:45AM -0800, Luck, Tony wrote:
> > Hrm, it may be doing this.  I wonder how that works though with 4GB's
> > of RAM installed?
> 
> Systems with 4G of RAM usually map part of the RAM above 4G so as to
> leave a hole for i/o mapping etc.

exactly.
rx2600 physical memory map only has 1GB of RAM below 4GB address space.

grant
