From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date: Thu, 06 May 2004 15:08:38 +0000
Subject: Re: [2.6.6 PATCH] Exposing EFI memory map
Message-Id: <200405060908.39311.bjorn.helgaas@hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <004801c4336c$daae5840$39624c0f@india.hp.com>
In-Reply-To: <004801c4336c$daae5840$39624c0f@india.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Sourav Sen <souravs@india.hp.com>
Cc: 'Matt Domsch' <Matt_Domsch@dell.com>, matthew.e.tolentino@intel.com, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, tony.luck@intel.com

On Thursday 06 May 2004 7:20 am, Sourav Sen wrote:
> + 1) Why does userspace / humans need to know this?  For 
> + debugging firmware?
> 	
> 	Maybe. But the point I had in mind is, say for example
> memory diagnostics applications/exercisers which reads (Blind
> reads, without caring about contents) memory
> to uncover errors (single bit errors)  can use
> this to know the usable ranges and map them thru /dev/mem and
> read those ranges.

For this application, the EFI memory map isn't what you want.
It's a pretty good approximation today, but the day when we'll
be able to hot-add memory is fast approaching, and the EFI map
won't mention anything added after boot.  We'll discover all
that via ACPI (on ia64).
