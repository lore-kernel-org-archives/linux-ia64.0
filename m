From: Davidlohr Bueso <dave@stgolabs.net>
Date: Thu, 07 Apr 2016 06:58:07 +0000
Subject: Re: [PATCH 03/11] locking, rwsem: introduce basis for down_write_killable
Message-Id: <20160407065807.GA29020@linux-uzut.site>
List-Id: <linux-ia64.vger.kernel.org>
References: <1459508695-14915-1-git-send-email-mhocko@kernel.org>
 <1459508695-14915-4-git-send-email-mhocko@kernel.org>
 <20160402044125.GC5329@linux-uzut.site>
 <20160404091659.GA13463@dhcp22.suse.cz>
In-Reply-To: <20160404091659.GA13463@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Michal Hocko <mhocko@kernel.org>
Cc: LKML <linux-kernel@vger.kernel.org>, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, "David S. Miller" <davem@davemloft.net>, Tony Luck <tony.luck@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Chris Zankel <chris@zankel.net>, Max Filippov <jcmvbkbc@gmail.com>, x86@kernel.org, linux-alpha@vger.kernel.org, linux-ia64@vger.kernel.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, linux-xtensa@linux-xtensa.org, linux-arch@vger.kernel.org

On Mon, 04 Apr 2016, Michal Hocko wrote:

>Not sure I got your point here.

You set current to TASK_KILLABLE in the sleep loop, why do you want to change
it here to TASK_RUNNING if its about to be killed? At least in the case of
UNINTERRUPTABLE we do it merely as a redundancy after the breaking out of the
loop. Of course we also acquired the lock in the first place by that time and
we _better_ be running.

Thanks,
Davidlohr
