From: Ingo Molnar <mingo@kernel.org>
Date: Thu, 31 Mar 2016 09:20:05 +0000
Subject: Re: [PATCH 0/11] introduce down_write_killable for rw_semaphore
Message-Id: <20160331092005.GA18640@gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1456750705-7141-1-git-send-email-mhocko@kernel.org>
 <20160330133217.GV3408@twins.programming.kicks-ass.net>
 <20160331085926.GB27831@dhcp22.suse.cz>
In-Reply-To: <20160331085926.GB27831@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Michal Hocko <mhocko@kernel.org>
Cc: Peter Zijlstra <peterz@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Ingo Molnar <mingo@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, "David S. Miller" <davem@davemloft.net>, Tony Luck <tony.luck@intel.com>, Chris Zankel <chris@zankel.net>, Max Filippov <jcmvbkbc@gmail.com>, x86@kernel.org, linux-alpha@vger.kernel.org, linux-ia64@vger.kernel.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, linux-xtensa@linux-xtensa.org, linux-arch@vger.kernel.org


* Michal Hocko <mhocko@kernel.org> wrote:

> On Wed 30-03-16 15:32:17, Peter Zijlstra wrote:
> > On Mon, Feb 29, 2016 at 01:58:14PM +0100, Michal Hocko wrote:
> > > I have tested on x86 with OOM situations with high mmap_sem contention
> > > (basically many parallel page faults racing with many parallel mmap/munmap
> > > tight loops) so the waiters for the write locks are routinely interrupted
> > > by SIGKILL.
> > 
> > Aside from the one niggle (as per the other email) they look good to me
> > and I would take them through the tip/locking tree.
> 
> Thanks for the review! I understand that tip/locking would be the most 
> appropriate place [...]

Yes.

> [...] but I am wondering whether this causes some issues with the follow up 
> patches which use this new API and which I expect to go via Andrew's tree.

So AFAIK Andrew's tree is based on top of linux-next, so once it goes into 
tip:locking/core, -mm can pick it up as well 1-2 days later.

Please send the changes in isolation, for merge into the locking tree.

Thanks,

	Ingo
