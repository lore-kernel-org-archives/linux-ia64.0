From: Mike Galbraith <efault@gmx.de>
Date: Thu, 22 May 2003 16:25:54 +0000
Subject: [Linux-ia64] Re: web page on O(1) scheduler
Message-Id: <marc-linux-ia64-105590723705984@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705966@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705966@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

At 11:52 AM 5/22/2003 +0200, Mike Galbraith wrote:
>At 10:56 AM 5/21/2003 -0700, David Mosberger wrote:
>> >>>>> On Wed, 21 May 2003 11:26:31 +0200, Mike Galbraith <efault@gmx.de> 
>> said:
>>
>>   Mike> The page mentions persistent starvation.  My own explorations
>>   Mike> of this issue indicate that the primary source is always
>>   Mike> selecting the highest priority queue.
>>
>>My working assumption is that the problem is a bug with the dynamic
>>prioritization.  The task receiving the signals calls sleep() after
>>handling a signal and hence it's dynamic priority should end up higher
>>than the priority of the task sending signals (since the sender never
>>relinquishes the CPU voluntarily).
>>
>>However, I haven't actually had time to look at the relevant code, so
>>I may be missing something.  If you understand the issue better,
>>please explain to me why this isn't a dynamic priority issue.
>
>You're right, it looks like a corner case.

Out of curiosity, is someone hitting that with a real program?

         -Mike

aside:
if so, I suppose nano-ticks may be needed.  rounding up gave us too many 
"nano-ticks", and was the first problem with irman, which brought round 
down into activate_task().  now, test-starve.c appears, and it turns out to 
be too many nano-ticks _missing_.  (rounding up doesn't "fix" that one btw 
[too fast], but what I did to demonstrate the problem does re-break irman 
rather nicely:) 


