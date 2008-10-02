From: Jay Lan <jlan@sgi.com>
Date: Thu, 02 Oct 2008 17:04:24 +0000
Subject: Re: kdump broken on Altix 350
Message-Id: <48E4FF18.10405@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <57C9024A16AD2D4C97DC78E552063EA34DB4172D@orsmsx505.amr.corp.intel.com>	<200809292342.m8TNgq4u004680@agluck-lia64.sc.intel.com>
	<20081002051348.GA1027@verge.net.au>
In-Reply-To: <20081002051348.GA1027@verge.net.au>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Simon Horman <horms@verge.net.au>
Cc: "kexec@lists.infradead.org" <kexec@lists.infradead.org>, Bernhard Walle <bwalle@suse.de>, "Luck, Tony" <tony.luck@intel.com>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>

Simon Horman wrote:
> On Mon, Sep 29, 2008 at 04:42:52PM -0700, Luck, Tony wrote:
>> Does this make kexec/kdump happier?  Bare minimum testing so far
>> (builds and boots on tiger ... didn't try kexec yet).
> 
> Hi Tony,
> 
> your analysis (in your previous email) was more or less the same
> conclusion that I had come too, though I was puzzling over
> why you had put the reserved area for cpu0 where you had - I assumed
> I was misunderstanding things.
> 
> This patch looks good to me.
> 
> Jay,
> 
> With this patch I assume that we still need an order of operations fix for
> kexec-tools but no section merging changes. Is that correct?

I think the code should still be simplified.

The 'break' of the if-statement has never been executed due to
the mistake in operation precedence. Thus, the code have been
doing segment merging by calculating p_memsz of each segment
without having to deal with 'gap' between PT_LOAD headers.

As demonstrated by this incidence, when there is a gap happened,
the kernel boot fail. So, if we assume the PT_LOAD headers will
be generated correctly, then the segment merging logic should be
simplified. It does not make sense to pick up p_memsz of each
segment and do all those calculation. It caused confusion.

Regards,
jay
