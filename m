From: Matthew Leach <matthew@mattleach.net>
Date: Thu, 06 Aug 2015 18:44:37 +0000
Subject: Re: [BUG]: Intel uncore boot warning introduced in 4.1
Message-Id: <87a8u4b6ju.fsf@mattleach.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <1438853676.3139.20.camel@mattleach.net>
	<87bneko0o5.fsf@mattleach.net>
	<37D7C6CF3E00A74B8858931C1DB2F077018D32C2@SHSMSX103.ccr.corp.intel.com>
In-Reply-To: <37D7C6CF3E00A74B8858931C1DB2F077018D32C2@SHSMSX103.ccr.corp.intel.com>
	(Kan Liang's message of "Thu, 6 Aug 2015 18:10:40 +0000")
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Liang, Kan" <kan.liang@intel.com>
Cc: Ingo Molnar <mingo@kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, "eranian@google.com" <eranian@google.com>, 'Andi Kleen' <ak@linux.intel.com>, 'Bjorn Helgaas' <bhelgaas@google.com>, 'Vince Weaver' <vincent.weaver@maine.edu>, 'Peter Zijlstra' <peterz@infradead.org>, 'Sonny Rao' <sonnyrao@chromium.org>

Hi Kan,

"Liang, Kan" <kan.liang@intel.com> writes:

[...]

> Matthew,
>
> Could you please revert
> 15c1247953e8a45232ed5a5540f291d2d0a77665
> and apply the patch https://lkml.org/lkml/2015/4/26/294?
> See if it works?

That works for me.  I no longer get the warning in my kernel boot log.

Thanks,
Matt
