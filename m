From: Mike Galbraith <efault@gmx.de>
Date: Wed, 21 May 2003 20:46:15 +0000
Subject: [Linux-ia64] Re: web page on O(1) scheduler
Message-Id: <marc-linux-ia64-105590723705975@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705966@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705966@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

At 10:56 AM 5/21/2003 -0700, David Mosberger wrote:
> >>>>> On Wed, 21 May 2003 11:26:31 +0200, Mike Galbraith <efault@gmx.de> 
> said:
>
>   Mike> The page mentions persistent starvation.  My own explorations
>   Mike> of this issue indicate that the primary source is always
>   Mike> selecting the highest priority queue.
>
>My working assumption is that the problem is a bug with the dynamic
>prioritization.  The task receiving the signals calls sleep() after
>handling a signal and hence it's dynamic priority should end up higher
>than the priority of the task sending signals (since the sender never
>relinquishes the CPU voluntarily).

The only thing that matters is how much you sleep vs run, so yes, it should 
have a higher priority unless that handling is heavy on cpu.  If it 
doesn't, then you have to have a different problem, because the dynamic 
priority portion of the scheduler is dead simple.  The only way I can 
imagine that priority could end up lower than expected is heavyweight 
interrupt load, or spinning out of control.

>However, I haven't actually had time to look at the relevant code, so
>I may be missing something.  If you understand the issue better,
>please explain to me why this isn't a dynamic priority issue.

I just saw your other post regarding the web page.  Now that I know that 
there's a detailed description in there somewhere, I'll go read it and see 
if any of what I've gleaned from crawling around the scheduler code is 
useful.  I thought you might be encountering the same kind of generic 
starvation I've seen.  Ergo, the simple diag patch.

         -Mike 


