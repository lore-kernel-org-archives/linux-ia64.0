From: "Villacis, Juan" <juan.villacis@intel.com>
Date: Thu, 25 Oct 2007 11:05:18 +0000
Subject: RE: [PATCH] IA64/perfmon: kill dead code, clean irq handling
Message-Id: <176273AE807A344A8C14F517A8FC59C20259A09E@scsmsx412.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20071023230908.GA12417@havoc.gtf.org> <20071025084615.GA32656@frankl.hpl.hp.com> <4720592D.4030604@garzik.org>
In-Reply-To: <4720592D.4030604@garzik.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Jeff Garzik <jeff@garzik.org>, eranian@hpl.hp.com
Cc: "Luck, Tony" <tony.luck@intel.com>, linux-ia64@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, "Stone, Joshua I" <joshua.i.stone@intel.com>

Hi,

The VTune sampling driver currently uses this hook for cases where it
needs to do its own handling of the PMU on platforms that Perfmon2 may
not yet (fully, correctly) recognize at the time of the kernel's
release.

-juan 

-----Original Message-----
From: Jeff Garzik [mailto:jeff@garzik.org] 
Sent: Thursday, October 25, 2007 1:52 AM
To: eranian@hpl.hp.com
Cc: Luck, Tony; linux-ia64@vger.kernel.org; Andrew Morton; LKML; Stone,
Joshua I; Villacis, Juan
Subject: Re: [PATCH] IA64/perfmon: kill dead code, clean irq handling

Stephane Eranian wrote:
> Jeff,
> 
> On Tue, Oct 23, 2007 at 07:09:08PM -0400, Jeff Garzik wrote:
>> By deleting unused code, this makes perfmon irq handling more
efficient,
>> as well as reducing code size.
>>
>> * remove unused pfm_install_alt_pmu_interrupt()
>> * remove unused pfm_remove_alt_pmu_interrupt()
>>
> I have not problem with the patch except maybe for those two
functions.
> How do you know they are not used?
> Have you checked the VTUNE open-source driver?
> I thought at some point they were using this hook.

I was hoping some IA-64 person could speak authoritatively on the
subject :)

	Jeff
