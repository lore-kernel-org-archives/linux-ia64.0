From: Eric Piel <Eric.Piel@Bull.Net>
Date: Fri, 14 Mar 2003 14:34:36 +0000
Subject: [Linux-ia64] Re: [BUG] nanosleep() granularity bumps up in 2.5.64 (was: [PATCH]
Message-Id: <marc-linux-ia64-105590709806094@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

David Mosberger wrote:
> Are you running ntp?
Yes (I hadn't noticed it) but it was not connected to any server and
disabling it doesn't change the results.
 

> 
> On 2.5:
> 
>         $ time sleep 16
>         real    0m16.002s
>         user    0m0.001s
>         sys     0m0.002s
> 
>         $ time sleep 16.02
>         real    0m25.189s
>         user    0m0.000s
>         sys     0m0.001s
> 
> So clearly something very strange is going on.  My suspicion is that
> the bug was introduced back when x86 switched from 100Hz to 1000Hz
> ticks, but that's just a guess.  Eric, would you be
> able/willing/interested to look into this?
Sure, I aim at porting the high resolution timers but any annoying bug
related to the time can be interesting to remove.

Coincidently Vita has just reported a bug on the lkml which, after a
closer look, seems to be the same:
>   When playing with select() timeout values I found that granularity
> of nanosleep() in 2.5.64 kernel bumps to 256 msec. Trying to get finer
> granularity it ends up sleeping to the next multiple of 256 msec

From what I understand their is a bug in the timers that causes a big
granularity. The case of Vita is a very good example. Also, after 16s it
seems the granuality (slowly?!) jumps from 1/64th s to 16s! :
sleep requested	 time obtained
14.000000000     14.006201744
15.000000000     15.006647110
16.000000000     16.007089615
17.000000000     18.742679596
18.000000000     32.014190674
19.000000000     32.014190674
20.000000000     32.014190674

I think lines like that from patch-2.5.64 are very suspicious to be
related to the bug:
+	base->timer_jiffies = INITIAL_JIFFIES;
+	base->tv1.index = INITIAL_JIFFIES & TVR_MASK;
+	base->tv2.index = (INITIAL_JIFFIES >> TVR_BITS) & TVN_MASK;
+	base->tv3.index = (INITIAL_JIFFIES >> (TVR_BITS+TVN_BITS)) & TVN_MASK;
+	base->tv4.index = (INITIAL_JIFFIES >> (TVR_BITS+2*TVN_BITS)) &
TVN_MASK;
+	base->tv5.index = (INITIAL_JIFFIES >> (TVR_BITS+3*TVN_BITS)) &
TVN_MASK;

Any idea/sugestion/patch is welcomed. Whatever, I will try to fix this
as soon as I'm back from my week end :-)

	Eric

