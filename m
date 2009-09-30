From: "Luck, Tony" <tony.luck@intel.com>
Date: Wed, 30 Sep 2009 22:05:43 +0000
Subject: RE: [PATCHSET percpu#for-next] percpu: convert ia64 to dynamic
Message-Id: <57C9024A16AD2D4C97DC78E552063EA3E2F03FDC@orsmsx505.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1253682382-24740-1-git-send-email-tj@kernel.org>
 <4AC153EA.2050007@suse.de>
 <57C9024A16AD2D4C97DC78E552063EA3E2F03E58@orsmsx505.amr.corp.intel.com>
 <alpine.DEB.1.10.0909301644460.9271@gentwo.org>
In-Reply-To: <alpine.DEB.1.10.0909301644460.9271@gentwo.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Christoph Lameter <cl@linux-foundation.org>
Cc: Tejun Heo <teheo@suse.de>, Nick Piggin <npiggin@suse.de>, "Yu, Fenghua" <fenghua.yu@intel.com>, linux-ia64 <linux-ia64@vger.kernel.org>, Ingo Molnar <mingo@redhat.com>, Rusty Russell <rusty@rustcorp.com.au>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

> Tony: Could we use a global register for the per cpu address? That would
> make IA64 work similar to sparc.

Would that be a useful trade of resources for convenience?  We've already
hard-wired r13 for "current". Grabbing another one would require fixing
(since user code will have clobbered it).  Possibly re-working any existing
code that already uses whatever register you choose.

How would that compare with using [r13]?

We might have a krN free ... but kregs are a lot slower than real registers.

-Tony
