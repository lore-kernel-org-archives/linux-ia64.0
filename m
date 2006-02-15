From: Thomas Renninger <trenn@suse.de>
Date: Wed, 15 Feb 2006 17:49:48 +0000
Subject: Re: [PATCH] ACPI: fix vendor resource length computation
Message-Id: <43F369BC.9050604@suse.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <971FCB6690CD0E4898387DBF7552B90E045AACFA@orsmsx403.amr.corp.intel.com>
In-Reply-To: <971FCB6690CD0E4898387DBF7552B90E045AACFA@orsmsx403.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Moore, Robert" <robert.moore@intel.com>
Cc: Bjorn Helgaas <bjorn.helgaas@hp.com>, Andreas Schwab <schwab@suse.de>, "Luck, Tony" <tony.luck@intel.com>, "Brown, Len" <len.brown@intel.com>, linux-acpi@vger.kernel.org, linux-ia64@vger.kernel.org, Andrew Morton <akpm@osdl.org>, efocht@hpce.nec.com

Moore, Robert wrote:
> I think the original code may have been attempting to subtract off the
> size of the descriptor header to obtain the length of the vendor data
> bytes. However, something like a global replace may have broken it.
> 
Thanks, this one fixes the mem corruption.
Unaligned access messages still remain...


   Thomas
