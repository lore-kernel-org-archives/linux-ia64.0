From: Jes Sorensen <jes@sgi.com>
Date: Wed, 15 Feb 2006 14:56:20 +0000
Subject: Re: [PATCH] ia64: simplify and fix udelay()
Message-Id: <yq0y80cy8kr.fsf@jaguar.mkp.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <200602150908.k1F98dg02934@unix-os.sc.intel.com>
In-Reply-To: <200602150908.k1F98dg02934@unix-os.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Cc: hawkes@sgi.com, Tony Luck <tony.luck@gmail.com>, Andrew Morton <akpm@osdl.org>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, Jack Steiner <steiner@sgi.com>, Robin Holt <holt@sgi.com>, Dimitri Sivanich <sivanich@sgi.com>

>>>>> "Ken" = Chen, Kenneth W <kenneth.w.chen@intel.com> writes:

Ken> hawkes@sgi.com wrote on Tuesday, February 14, 2006 10:40 AM
>> a preemption and migration to another CPU during the while-loop

Ken> Off topic from the subject line a bit, but related: how many
Ken> Altix SN2 customers in the field turn on CONFIG_PREEMPT? Redhat
Ken> EL4 doesn't turn on preempt, SuSE SLES9 and SLES10 beta don't
Ken> turn it on either.  Is there a real benefit of turning that
Ken> option on for SN2?

Ken,

Not sure if any do, however as long as it's a supported kernel option
then we ought to make sure the kernel is reliable under it. Who knows,
at some point some distro might even decide to switch it on as well
(as much as I would discourage doing so ;).

Cheers,
Jes
