From: Ingo Molnar <mingo@kernel.org>
Date: Thu, 10 Mar 2016 10:24:13 +0000
Subject: Re: [RFC 0/12] introduce down_write_killable for rw_semaphore
Message-Id: <20160310102412.GA21593@gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1454444369-2146-1-git-send-email-mhocko@kernel.org>
 <20160309121850.GA14915@gmail.com>
 <20160309125641.GH27018@dhcp22.suse.cz>
 <20160309131710.GB7978@gmail.com>
 <20160309132855.GI27018@dhcp22.suse.cz>
 <20160309134339.GA20911@gmail.com>
 <20160309144140.GJ27018@dhcp22.suse.cz>
In-Reply-To: <20160309144140.GJ27018@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Michal Hocko <mhocko@kernel.org>
Cc: LKML <linux-kernel@vger.kernel.org>, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, "David S. Miller" <davem@davemloft.net>, Tony Luck <tony.luck@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Chris Zankel <chris@zankel.net>, Max Filippov <jcmvbkbc@gmail.com>, x86@kernel.org, linux-alpha@vger.kernel.org, linux-ia64@vger.kernel.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, linux-xtensa@linux-xtensa.org, linux-arch@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>


* Michal Hocko <mhocko@kernel.org> wrote:

> > > Why? Each syscall already is killable as the task might be killed by the OOM 
> > > killer.
> > 
> > Not all syscalls are interruptible - for example sys_sync() isn't:
> 
> I guess we are talking past each other. [...]

Heh, you are being polite, I think what happened is that I was being dense and 
didn't understand your point:

> [...] What I meant was that while all syscalls are allowed to not return to the 
> userspace because the task might get killed but not all of them accept to get 
> interrupted by a signal and return with EINTR. None of the man page of mmap, 
> mremap, mlock, mprotect list EINTR as a possibility so I would be really afraid 
> of returning an unexpected error code.

Indeed.

> Does this make more sense now?

It does!

Thanks,

	Ingo
