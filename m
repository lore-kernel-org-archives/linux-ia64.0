From: Tejun Heo <tj@kernel.org>
Date: Tue, 22 Sep 2009 21:50:15 +0000
Subject: Re: [PATCHSET percpu#for-next] percpu: convert ia64 to dynamic	percpu
Message-Id: <4AB94697.3030100@kernel.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <1253605214-23210-1-git-send-email-tj@kernel.org> <20090922081631.GD1475@elte.hu> <57C9024A16AD2D4C97DC78E552063EA3E29CCA8E@orsmsx505.amr.corp.intel.com> <57C9024A16AD2D4C97DC78E552063EA3E29CCADC@orsmsx505.amr.corp.intel.com> <57C9024A16AD2D4C97DC78E552063EA3E29CCB18@orsmsx505.amr.corp.intel.com>
In-Reply-To: <57C9024A16AD2D4C97DC78E552063EA3E29CCB18@orsmsx505.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Luck, Tony" <tony.luck@intel.com>
Cc: Ingo Molnar <mingo@elte.hu>, Nick Piggin <npiggin@suse.de>, "Yu, Fenghua" <fenghua.yu@intel.com>, linux-ia64 <linux-ia64@vger.kernel.org>, Ingo Molnar <mingo@redhat.com>, Rusty Russell <rusty@rustcorp.com.au>, Christoph Lameter <cl@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

Hello,

Luck, Tony wrote:
> I just noticed the "#for-next" in the Subject line for these
> patches.  Do they depend on some stuff in linux-next that is
> not in Linus' tree (pulled today HEADa07729e...)?  If so, then
> ignore my results.

Nope, it should work on top of Linus's tree.

> Kernel built from generic_defconfig does boot OK though, so I suspect
> this is a discontig vs. contig problem.

Yeah, it's probably something broken with contig SMP configuration.
I've just found a machine with contig mem and multiple processors.
Will test on it later today.

Thanks.

-- 
tejun
