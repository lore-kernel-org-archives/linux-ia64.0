From: Jeff Garzik <jeff@garzik.org>
Date: Thu, 25 Oct 2007 08:51:57 +0000
Subject: Re: [PATCH] IA64/perfmon: kill dead code, clean irq handling
Message-Id: <4720592D.4030604@garzik.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20071023230908.GA12417@havoc.gtf.org> <20071025084615.GA32656@frankl.hpl.hp.com>
In-Reply-To: <20071025084615.GA32656@frankl.hpl.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: eranian@hpl.hp.com
Cc: tony.luck@intel.com, linux-ia64@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, joshua.i.stone@intel.com, juan.villacis@intel.com

Stephane Eranian wrote:
> Jeff,
> 
> On Tue, Oct 23, 2007 at 07:09:08PM -0400, Jeff Garzik wrote:
>> By deleting unused code, this makes perfmon irq handling more efficient,
>> as well as reducing code size.
>>
>> * remove unused pfm_install_alt_pmu_interrupt()
>> * remove unused pfm_remove_alt_pmu_interrupt()
>>
> I have not problem with the patch except maybe for those two functions.
> How do you know they are not used?
> Have you checked the VTUNE open-source driver?
> I thought at some point they were using this hook.

I was hoping some IA-64 person could speak authoritatively on the subject :)

	Jeff



