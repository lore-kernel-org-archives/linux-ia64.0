From: Zoltan Menyhart <Zoltan.Menyhart@bull.net>
Date: Wed, 01 Aug 2007 09:38:34 +0000
Subject: Re: [PATCH] flush icache before set_pte take6. [4/4] optimization
Message-Id: <46B0549A.1010308@bull.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <617E1C2C70743745A92448908E030B2A020E3B1C@scsmsx411.amr.corp.intel.com>
In-Reply-To: <617E1C2C70743745A92448908E030B2A020E3B1C@scsmsx411.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Luck, Tony" <tony.luck@intel.com>
Cc: David Mosberger-Tang <dmosberger@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, LKML <linux-kernel@vger.kernel.org>, linux-ia64@vger.kernel.org, Christoph Lameter <clameter@sgi.com>

Luck, Tony wrote:
>>This seems crazy to me.  Flushing should occur according to the
>>*architecture*, not model-by-model.  Even if we happen to get "lucky"
>>on pre-Montecito CPUs, that doesn't justify such ugly hacks.  Or you
>>really want to debug this *again* come next CPU?
> 
> 
> Ditto.  The only reason we should ever have model specific checks should
> be to work around model specific errata (e.g. the McKinley Errata #9 code
> in patch.c).

You do have model specific I cache semantics.
Not taking it into account will oblige you to flush in vain for the models
which do not require it. Why do you want to take this option?


Thanks,

Zoltan
