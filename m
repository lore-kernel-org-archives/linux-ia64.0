From: "Luck, Tony" <tony.luck@intel.com>
Date: Tue, 22 Sep 2009 21:24:30 +0000
Subject: RE: [PATCHSET percpu#for-next] percpu: convert ia64 to dynamic
Message-Id: <57C9024A16AD2D4C97DC78E552063EA3E29CCB18@orsmsx505.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1253605214-23210-1-git-send-email-tj@kernel.org>
 <20090922081631.GD1475@elte.hu>
 <57C9024A16AD2D4C97DC78E552063EA3E29CCA8E@orsmsx505.amr.corp.intel.com>
 <57C9024A16AD2D4C97DC78E552063EA3E29CCADC@orsmsx505.amr.corp.intel.com>
In-Reply-To: <57C9024A16AD2D4C97DC78E552063EA3E29CCADC@orsmsx505.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Luck, Tony" <tony.luck@intel.com>, Ingo Molnar <mingo@elte.hu>, Tejun Heo <tj@kernel.org>
Cc: Nick Piggin <npiggin@suse.de>, "Yu, Fenghua" <fenghua.yu@intel.com>, linux-ia64 <linux-ia64@vger.kernel.org>, Ingo Molnar <mingo@redhat.com>, Rusty Russell <rusty@rustcorp.com.au>, Christoph Lameter <cl@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

I just noticed the "#for-next" in the Subject line for these
patches.  Do they depend on some stuff in linux-next that is
not in Linus' tree (pulled today HEADa07729e...)?  If so, then
ignore my results.

Kernel built from generic_defconfig does boot OK though, so I suspect
this is a discontig vs. contig problem.

-Tony
