From: Mike Galbraith <efault@gmx.de>
Date: Thu, 22 May 2003 05:52:44 +0000
Subject: [Linux-ia64] Re: web page on O(1) scheduler
Message-Id: <marc-linux-ia64-105590723705981@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705966@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705966@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

At 08:38 PM 5/21/2003 -0400, Rik van Riel wrote:
>On Wed, 21 May 2003, Mike Galbraith wrote:
> > At 11:49 PM 5/20/2003 -0700, David Mosberger wrote:
> > >Recently, I started to look into some odd performance behaviors of the
> > >O(1) scheduler.  I decided to document what I found in a web page
> > >at:
> > >
> > >         http://www.hpl.hp.com/research/linux/kernel/o1.php
> >
> > The page mentions persistent starvation.  My own explorations of this
> > issue indicate that the primary source is always selecting the highest
> > priority queue.
>
>It's deeper than that.  The O(1) scheduler doesn't consider
>actual CPU usage as a factor of CPU priority.

Oh, there's no doubt in my mind that it's _much_ deeper than my little 
surface scratchings ;-)

It does consider cpu usage though.  Your run history is right there in your 
accumulated sleep_avg.  Unfortunately (in some ways, fortunate in others.. 
conflict) that information can be diluted down to nothing instantly by new 
input from one wakeup.

         -Mike 


