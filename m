From: Andi Kleen <ak@suse.de>
Date: Fri, 04 Jun 2004 11:02:34 +0000
Subject: Re: sched_clock
Message-Id: <20040604110234.GF28362@wotan.suse.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <40B4868F.B649611C@nospam.org>
In-Reply-To: <40B4868F.B649611C@nospam.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Fri, Jun 04, 2004 at 05:43:08AM -0400, Ingo Molnar wrote:
> 
> On Thu, 3 Jun 2004, David Mosberger wrote:
> 
> > Ingo, is there something on x86 that guarantees that the cycle-counter
> > will start out near zero at boot time?
> 
> it starts at zero, but there's no guarantee as far as i know. Would there
> be any reason for it to start at another reason?

Software can change it using MSR 1.  One reason might be that the easiest way 
to synchronize them for multiple CPUs at boot time is to set it to
a high future value. But I don't know of any BIOS that does that.

At one point we considered doing it ourselves on x86-64 to store the 
CPU number in the high bits for fast and race free per CPU gettimefoday.
But so far this hasn't been done. This won't work on i386 because
older Intel CPUs don't allow to write the full 64bits.

BTW I had code relying on the TSC not wrapping in the x86-64 kernel
for some time (now fixed), but nothing bad has happened.

-Andi
