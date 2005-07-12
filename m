From: "Luck, Tony" <tony.luck@intel.com>
Date: Tue, 12 Jul 2005 19:39:55 +0000
Subject: RE: [PATCH] fix call of smp_processor_id() by XPC while preemptible
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F03E3D6D5@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <42D41A65.mailx8QB11670O@aqua.americas.sgi.com>
In-Reply-To: <42D41A65.mailx8QB11670O@aqua.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>XPC calls smp_processor_id() twice from xpc_setup_infrastructure() with
>preemption enabled, which gets flagged if 'DEBUG_PREEMPT=y'. This patch
>disables preemption around a now single call to smp_processor_id(). Note
>that it doesn't matter if the thread is moved to another processor once
>it has the processor ID.

So the code becomes effectively:

	cpuid = pick_a_random_online_cpuid();

What is the higher level function that you are doing here that is OK
with that?

-Tony

P.S. The cpu number you picked may not still be online by the time
you use it.
