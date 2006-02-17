From: "Luck, Tony" <tony.luck@intel.com>
Date: Fri, 17 Feb 2006 19:52:45 +0000
Subject: RE: Problems with MSI-X on ia64
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F05BF610F@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <D4CFB69C345C394284E4B78B876C1CF10B848090@cceexc23.americas.cpqcorp.net>
In-Reply-To: <D4CFB69C345C394284E4B78B876C1CF10B848090@cceexc23.americas.cpqcorp.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Chris Wedgwood <cw@f00f.org>, Grant Grundler <grundler@parisc-linux.org>
Cc: Greg KH <gregkh@suse.de>, linux-kernel@vger.kernel.org, linux-scsi@vger.kernel.org, linux-ia64@vger.kernel.org, linux-pci@atrey.karlin.mff.cuni.cz, "Miller, Mike (OS Dev)" <Mike.Miller@hp.com>, Jesse Barnes <jbarnes@virtuousgeek.org>

> Hrm, it may be doing this.  I wonder how that works though with 4GB's
> of RAM installed?

Systems with 4G of RAM usually map part of the RAM above 4G so as to
leave a hole for i/o mapping etc.

-Tony
