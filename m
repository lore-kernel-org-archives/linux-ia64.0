From: ebiederm@xmission.com (Eric W. Biederman)
Date: Tue, 11 Aug 2009 19:57:00 +0000
Subject: Re: [RFC Patch 2/2] kexec: allow to shrink reserved memory
Message-Id: <m1r5vi9l9v.fsf@fess.ebiederm.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20090811104144.5154.77871.sendpatchset@localhost.localdomain>
	<20090811104154.5154.78710.sendpatchset@localhost.localdomain>
In-Reply-To: <20090811104154.5154.78710.sendpatchset@localhost.localdomain> (Amerigo Wang's message of "Tue\, 11 Aug 2009 06\:39\:32 -0400")
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Amerigo Wang <amwang@redhat.com>
Cc: linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, Neil Horman <nhorman@redhat.com>, Andi Kleen <andi@firstfloor.org>, akpm@linux-foundation.org, Ingo Molnar <mingo@elte.hu>

Amerigo Wang <amwang@redhat.com> writes:

> This patch implements shrinking the reserved memory for crash kernel,
> if it is more than enough.
>
> For example, if you have already reserved 128M, now you just want 100M,
> you can do:
>
> # echo $((100*1024*1024)) > /sys/kernel/kexec_crash_size

This patch looks like a reasonable start.

However once a crash kernel image is loaded we have already told that
image about the memory that is available and what you are doing here
will go and stop on the memory that is reserved but not yet used,
totally breaking the DMA protections.  AKA we know the memory is safe
from ongoing DMAs because it has lain fallow since boot up.

The only safe thing to do is to reduce the memory size before (possibly
just before) we load the crash kernel.  Which means we should only
be allowed to shrink the size when nothing is loaded, exactly the
opposite of what you have implemented.

You patch also plays with global kexec variables outside of the mutex
before calling into shrink_crash_memory.   If my memory serves just
doing mutx_lock(&kexec_mutex) on this code path should be fine.  The
mutex_trylock on the other code paths is about having non-blocking
behavior that you don't need here.

Eric
