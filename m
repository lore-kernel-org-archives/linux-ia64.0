From: Ingo Molnar <mingo@redhat.com>
Date: Fri, 04 Jun 2004 09:43:08 +0000
Subject: Re: sched_clock
Message-Id: <Pine.LNX.4.58.0406040541220.22011@devserv.devel.redhat.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <40B4868F.B649611C@nospam.org>
In-Reply-To: <40B4868F.B649611C@nospam.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


On Thu, 3 Jun 2004, David Mosberger wrote:

> Ingo, is there something on x86 that guarantees that the cycle-counter
> will start out near zero at boot time?

it starts at zero, but there's no guarantee as far as i know. Would there
be any reason for it to start at another reason?

	Ingo
