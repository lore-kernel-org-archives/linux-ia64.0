From: Andrew Morton <akpm@linux-foundation.org>
Date: Fri, 01 Apr 2016 09:11:49 +0000
Subject: Re: [PATCH 0/11] introduce down_write_killable for rw_semaphore
Message-Id: <20160401021149.1214b9ba97d33e7447a0deec@linux-foundation.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <1456750705-7141-1-git-send-email-mhocko@kernel.org>
	<20160330133217.GV3408@twins.programming.kicks-ass.net>
	<20160331085926.GB27831@dhcp22.suse.cz>
	<20160331092005.GA18640@gmail.com>
	<20160331100331.73eb381a45a1e03473f700a9@linux-foundation.org>
	<20160401072653.GA8916@dhcp22.suse.cz>
In-Reply-To: <20160401072653.GA8916@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Michal Hocko <mhocko@kernel.org>
Cc: Ingo Molnar <mingo@kernel.org>, Peter Zijlstra <peterz@infradead.org>, LKML <linux-kernel@vger.kernel.org>, Ingo Molnar <mingo@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, "David S. Miller" <davem@davemloft.net>, Tony Luck <tony.luck@intel.com>, Chris Zankel <chris@zankel.net>, Max Filippov <jcmvbkbc@gmail.com>, x86@kernel.org, linux-alpha@vger.kernel.org, linux-ia64@vger.kernel.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, linux-xtensa@linux-xtensa.org, linux-arch@vger.kernel.org

On Fri, 1 Apr 2016 09:26:54 +0200 Michal Hocko <mhocko@kernel.org> wrote:

> I was more worried about dependencies when you send your patch bomb to
> Linus because then it is an additional burden on you to watch for tip
> merge before you send yours.

That happens pretty often.  I haven't screwed it up yet ;)

Usually stuff just won't compile, but I always have little notes-to-self
in the series file reminding me to check stuff.
