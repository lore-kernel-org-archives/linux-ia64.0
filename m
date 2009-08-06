From: Amerigo Wang <amwang@redhat.com>
Date: Thu, 06 Aug 2009 01:45:04 +0000
Subject: Re: [Patch 2/7] x86: implement crashkernel=auto
Message-Id: <4A7A35A0.4040707@redhat.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20090805112123.6552.73574.sendpatchset@localhost.localdomain> <20090805112142.6552.18373.sendpatchset@localhost.localdomain> <20090805134342.GE7259@hmsreliant.think-freely.org>
In-Reply-To: <20090805134342.GE7259@hmsreliant.think-freely.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Neil Horman <nhorman@redhat.com>
Cc: linux-kernel@vger.kernel.org, tony.luck@intel.com, linux-ia64@vger.kernel.org, "Eric W. Biederman" <ebiederm@xmission.com>, akpm@linux-foundation.org, Ingo Molnar <mingo@elte.hu>, Anton Vorontsov <avorontsov@ru.mvista.com>

Neil Horman wrote:
> What about all the other arches that support kexec?  ia64/ppc[64]/s390/etc?
> Don't they need an implementation of arch_default_crash_size?  Or perhaps better
> still you should put this definition in asm-generic, so that it can be
> overridden per-arch if need be, but you always have something to fall back on.
>   

Hmm, I think you mean we need ARCH_HAS_XXXX....
OK, it is a good idea, I will try it.

Thanks for your review, Neil.

