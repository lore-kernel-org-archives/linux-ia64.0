From: Rik van Riel <riel@imladris.surriel.com>
Date: Thu, 22 May 2003 00:38:56 +0000
Subject: [Linux-ia64] Re: web page on O(1) scheduler
Message-Id: <marc-linux-ia64-105590723705979@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705966@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705966@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, 21 May 2003, Mike Galbraith wrote:
> At 11:49 PM 5/20/2003 -0700, David Mosberger wrote:
> >Recently, I started to look into some odd performance behaviors of the
> >O(1) scheduler.  I decided to document what I found in a web page
> >at:
> >
> >         http://www.hpl.hp.com/research/linux/kernel/o1.php
>
> The page mentions persistent starvation.  My own explorations of this
> issue indicate that the primary source is always selecting the highest
> priority queue.

It's deeper than that.  The O(1) scheduler doesn't consider
actual CPU usage as a factor of CPU priority.


Rik
-- 
Engineers don't grow up, they grow sideways.
http://www.surriel.com/		http://kernelnewbies.org/

