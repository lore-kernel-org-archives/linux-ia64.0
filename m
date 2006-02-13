From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date: Mon, 13 Feb 2006 22:33:53 +0000
Subject: Re: some new unaligned access while booting ia64 (HP rx2620)
Message-Id: <200602131533.53905.bjorn.helgaas@hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <971FCB6690CD0E4898387DBF7552B90E0452B0D7@orsmsx403.amr.corp.intel.com> <43F0D526.5010806@suse.de>
In-Reply-To: <43F0D526.5010806@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Thomas Renninger <trenn@suse.de>
Cc: "Moore, Robert" <robert.moore@intel.com>, "Luck, Tony" <tony.luck@intel.com>, "Brown, Len" <len.brown@intel.com>, linux-acpi@vger.kernel.org, linux-ia64@vger.kernel.org

On Monday 13 February 2006 11:51, Thomas Renninger wrote:
> Something is strange here.
> With rc2-gitXY I got this:
> 
> -----------------------------------------------------------------------
> slab error in cache_free_debugcheck(): cache `size-256': double free, or memory outside object was overwritten

This is unrelated to Tony's original "unaligned access" problem, right?

If I understand correctly, you have CONFIG_DEBUG_SLAB turned on, and
it reported a double free in the pci_acpi_scan_root() path in the rc2
kernel.  Then you tried rc3 and saw a similar slab problem in
the acpi_sba_ioc_add() path.

I looked at both of those paths, and I don't see anything wrong.  I
tried unsuccessfully to reproduce it with an rc1-mm4 kernel on an
rx2600.  I also tried an rc3 kernel (hg pull from 10 minutes ago)
and couldn't reproduce it.

You have ACPI debug stuff turned on, don't you?  I didn't enable that.
Can you reproduce the slab problem with that turned off?

