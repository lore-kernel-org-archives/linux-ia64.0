From: Rich Altmaier <richa@engr.sgi.com>
Date: Thu, 20 Mar 2003 23:55:02 +0000
Subject: Re: [Linux-ia64] provide /proc/sal/itc_drift through AUX?
Message-Id: <marc-linux-ia64-105590723705280@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705273@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705273@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Jes, regarding your query on real life ITC drifts, I have this input.
Typical crystals used for the CPU clock today have an accuracy
of 250ppm.  That is 250 parts per million.  Which means for each
million ticks, it may actually be 250 realtime units too fast or too slow.
So in one second's worth of 1GHz ticks, it may be wrong versus
realtime by 250 microseconds.  
(not to belabor the point, but then a 1 millisecond error accumulates
each 4 seconds).

In case you ask "how can this be, my digital watch is better than that".
Your watch is better designed, plus it has more temperature stability
on your arm.  Plus nobody is willing to buy expensive crystals
for the computer...

FYI, Rich
Rich Altmaier
SGI


Jes Sorensen wrote:
...
> 
> I think this would work if it wasn't for the different clock frequency
> problem. What real life ITC drifts are like I must admit I have no
> idea.
>

