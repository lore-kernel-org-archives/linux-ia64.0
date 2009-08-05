From: ebiederm@xmission.com (Eric W. Biederman)
Date: Wed, 05 Aug 2009 20:07:24 +0000
Subject: Re: [Patch 1/7] x86: add CONFIG_KEXEC_AUTO_RESERVE
Message-Id: <m163d2t477.fsf@fess.ebiederm.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20090805112123.6552.73574.sendpatchset@localhost.localdomain>
	<20090805112133.6552.69619.sendpatchset@localhost.localdomain>
	<87zlaeiakr.fsf@basil.nowhere.org>
In-Reply-To: <87zlaeiakr.fsf@basil.nowhere.org> (Andi Kleen's message of "Wed\, 05 Aug 2009 16\:45\:08 +0200")
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Andi Kleen <andi@firstfloor.org>
Cc: Amerigo Wang <amwang@redhat.com>, linux-kernel@vger.kernel.org, tony.luck@intel.com, linux-ia64@vger.kernel.org, Neil Horman <nhorman@redhat.com>, akpm@linux-foundation.org, Ingo Molnar <mingo@elte.hu>, Anton Vorontsov <avorontsov@ru.mvista.com>

Andi Kleen <andi@firstfloor.org> writes:

> Amerigo Wang <amwang@redhat.com> writes:
>
>> Introduce a new config option KEXEC_AUTO_RESERVE for x86.
>
> The description of the feature belongs in the changelog.
>
> I like the basic idea, but:
>
>> +config KEXEC_AUTO_RESERVE
>> +	bool "automatically reserve memory for kexec kernel"
>> +	depends on KEXEC
>> +	default y
>> +	---help---
>> +	  Automatically reserve memory for a kexec kernel, so that you don't
>> +	  need to specify numbers for the "crashkernel=X@Y" boot option,
>> +	  instead you can use "crashkernel=auto".
>> +	  On x86, 128M is reserved.
>
> The obvious problem is the hardcoded 128MB (and 128MB is very large
> for a crash kernel anyways)
>
> More useful would seem a crashkernel=size@auto

That is actually called "crashkernel=size" and we have had that for quite
a while.  Although some of the init scripts have problems.

Eric
