From: Mike Galbraith <efault@gmx.de>
Date: Wed, 21 May 2003 09:26:31 +0000
Subject: [Linux-ia64] Re: web page on O(1) scheduler
Message-Id: <marc-linux-ia64-105590723705967@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705966@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705966@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

At 11:49 PM 5/20/2003 -0700, David Mosberger wrote:
>Recently, I started to look into some odd performance behaviors of the
>O(1) scheduler.  I decided to document what I found in a web page
>at:
>
>         http://www.hpl.hp.com/research/linux/kernel/o1.php

<snip>

>Comments welcome.

The page mentions persistent starvation.  My own explorations of this issue 
indicate that the primary source is always selecting the highest priority 
queue.  Combine that with the round-robin, and you have a good chance of 
being grossly unfair with some workloads.  I know for certain that lock 
holders in the active array can be starved for very long periods by tasks 
entering higher priority queues, thereby causing even more starvation when 
they finally get the cpu and can release the lock (sleepers go through the 
roof).

Try the attached overly simplistic (KISS:) diff, and watch your starvation 
issues be very noticably reduced.

         -Mike 


