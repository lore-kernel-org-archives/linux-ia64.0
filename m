From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Fri, 04 Jun 2004 22:23:41 +0000
Subject: Re: sched_clock
Message-Id: <16576.63085.459570.276414@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <40B4868F.B649611C@nospam.org>
In-Reply-To: <40B4868F.B649611C@nospam.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Fri, 4 Jun 2004 05:43:08 -0400 (EDT), Ingo Molnar <mingo@redhat.com> said:

  Ingo> On Thu, 3 Jun 2004, David Mosberger wrote:

  >> Ingo, is there something on x86 that guarantees that the
  >> cycle-counter will start out near zero at boot time?

  Ingo> it starts at zero, but there's no guarantee as far as i
  Ingo> know. Would there be any reason for it to start at another
  Ingo> reason?

I was thinking that firmware might do some testing of the
cycle-counter and then leave the counter in an indeterminate state.
It's reasonable to expect that the firmware would clear the counter to
zero afterwards, but since it's not required by the specs, I wouldn't
want to _rely_ on it (especially if the resulting errors could be
obscure).  I think I'll go ahead and clear the cycle-counter in
cpu_init().  That ought to be safe.

	--david
