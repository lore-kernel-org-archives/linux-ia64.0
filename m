From: "Luck, Tony" <tony.luck@intel.com>
Date: Wed, 05 Apr 2006 22:50:30 +0000
Subject: RE: 2.6.17-rc1-mm1
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F06290233@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060404233851.GA6411@agluck-lia64.sc.intel.com>
In-Reply-To: <20060404233851.GA6411@agluck-lia64.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Bjorn Helgaas <bjorn.helgaas@hp.com>
Cc: "Zou, Nanhai" <nanhai.zou@intel.com>, Andrew Morton <akpm@osdl.org>, LKML <linux-kernel@vger.kernel.org>, linux-ia64@vger.kernel.org

> I think the VGA_MAP_MEM(vga_vram_end) is just bogus -- it's not
> that we need to map the memory starting at vga_vram_end.  I think
> it would cleaner (though much more intrusive) to do something like
> the patch below, which basically just hard-codes (base, size)
> rather than (base, end).

This patch works for me on ia64/Tiger

-Tony
