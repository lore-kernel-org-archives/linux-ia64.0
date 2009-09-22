From: "Luck, Tony" <tony.luck@intel.com>
Date: Tue, 22 Sep 2009 20:49:32 +0000
Subject: RE: [PATCHSET percpu#for-next] percpu: convert ia64 to dynamic
Message-Id: <57C9024A16AD2D4C97DC78E552063EA3E29CCA8E@orsmsx505.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1253605214-23210-1-git-send-email-tj@kernel.org>
 <20090922081631.GD1475@elte.hu>
In-Reply-To: <20090922081631.GD1475@elte.hu>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Ingo Molnar <mingo@elte.hu>, Tejun Heo <tj@kernel.org>
Cc: Nick Piggin <npiggin@suse.de>, "Yu, Fenghua" <fenghua.yu@intel.com>, linux-ia64 <linux-ia64@vger.kernel.org>, Ingo Molnar <mingo@redhat.com>, Rusty Russell <rusty@rustcorp.com.au>, Christoph Lameter <cl@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

> Contig memory model was verified with ski emulator.  Discontig and
> sparse models were verified on a 4-way SGI altix machine.  I've run
> percpu stress test module for quite a while on the machine.

Ski must have missed something.  I just tried to boot this on a
"tiger_defconfig" kernel[1] and it panic'd early in boot.  I'll need
to re-connect my serial console to get the useful part of the
panic message ... what's on the VGA console isn't very helpful :-(

-Tony

[1] uses contig.c
