From: Andi Kleen <andi@firstfloor.org>
Date: Wed, 05 Aug 2009 14:45:08 +0000
Subject: Re: [Patch 1/7] x86: add CONFIG_KEXEC_AUTO_RESERVE
Message-Id: <87zlaeiakr.fsf@basil.nowhere.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20090805112123.6552.73574.sendpatchset@localhost.localdomain>
	<20090805112133.6552.69619.sendpatchset@localhost.localdomain>
In-Reply-To: <20090805112133.6552.69619.sendpatchset@localhost.localdomain> (Amerigo Wang's message of "Wed, 5 Aug 2009 07:19:12 -0400")
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Amerigo Wang <amwang@redhat.com>
Cc: linux-kernel@vger.kernel.org, tony.luck@intel.com, linux-ia64@vger.kernel.org, Neil Horman <nhorman@redhat.com>, "Eric W. Biederman" <ebiederm@xmission.com>, akpm@linux-foundation.org, Ingo Molnar <mingo@elte.hu>, Anton Vorontsov <avorontsov@ru.mvista.com>

Amerigo Wang <amwang@redhat.com> writes:

> Introduce a new config option KEXEC_AUTO_RESERVE for x86.

The description of the feature belongs in the changelog.

I like the basic idea, but:

> +config KEXEC_AUTO_RESERVE
> +	bool "automatically reserve memory for kexec kernel"
> +	depends on KEXEC
> +	default y
> +	---help---
> +	  Automatically reserve memory for a kexec kernel, so that you don't
> +	  need to specify numbers for the "crashkernel=X@Y" boot option,
> +	  instead you can use "crashkernel=auto".
> +	  On x86, 128M is reserved.

The obvious problem is the hardcoded 128MB (and 128MB is very large
for a crash kernel anyways)

More useful would seem a crashkernel=size@auto

-Andi

-- 
ak@linux.intel.com -- Speaking for myself only.
