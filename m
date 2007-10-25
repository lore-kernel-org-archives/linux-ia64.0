From: Christoph Hellwig <hch@infradead.org>
Date: Thu, 25 Oct 2007 11:17:36 +0000
Subject: Re: [PATCH] IA64/perfmon: kill dead code, clean irq handling
Message-Id: <20071025111736.GA1414@infradead.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20071023230908.GA12417@havoc.gtf.org> <20071025084615.GA32656@frankl.hpl.hp.com> <4720592D.4030604@garzik.org> <176273AE807A344A8C14F517A8FC59C20259A09E@scsmsx412.amr.corp.intel.com>
In-Reply-To: <176273AE807A344A8C14F517A8FC59C20259A09E@scsmsx412.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Villacis, Juan" <juan.villacis@intel.com>
Cc: Jeff Garzik <jeff@garzik.org>, eranian@hpl.hp.com, "Luck, Tony" <tony.luck@intel.com>, linux-ia64@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, "Stone, Joshua I" <joshua.i.stone@intel.com>

On Thu, Oct 25, 2007 at 04:05:18AM -0700, Villacis, Juan wrote:
> Hi,
> 
> The VTune sampling driver currently uses this hook for cases where it
> needs to do its own handling of the PMU on platforms that Perfmon2 may
> not yet (fully, correctly) recognize at the time of the kernel's
> release.

So killing it might be a good way to make the vtune folks more cooperative.
Remember we don't keep hooks for crappy out of tree code around.
