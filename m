From: Christoph Lameter <clameter@sgi.com>
Date: Fri, 16 Jul 2004 02:44:13 +0000
Subject: Re: gettimeofday nanoseconds patch (makes it possible for the
Message-Id: <Pine.LNX.4.58.0407151941010.24953@schroedinger.engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.58.0407140940260.14704@schroedinger.engr.sgi.com>
 <1089835776.1388.216.camel@cog.beaverton.ibm.com> <40F70C6D.5050506@mvista.com>
In-Reply-To: <40F70C6D.5050506@mvista.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: George Anzinger <george@mvista.com>
Cc: john stultz <johnstul@us.ibm.com>, lkml <linux-kernel@vger.kernel.org>, ia64 <linux-ia64@vger.kernel.org>

On Thu, 15 Jul 2004, George Anzinger wrote:

> As to accuracy, the more "accurate" way is to change get_offset to return
> nanoseconds.  This way there is only one round off (by the divide) instead of
> two (the get_offset and the divide).  I ran into this problem in the latest HRT
> patch.  One of my tests is to do a gettimeofday and a clock_gettime and make
> sure there is no "backward" stuff happening.  Test failed by 1 micro second
> "some" of the time because of this double round off.

Well yes this is what the interpolator etc does on IA64.
time_interpolator_get_offset returns nanoseconds. I have done
tests to insure that no backward stuff happens. Tests were done
with the mentioned patch and clock_gettime was returning nanosecond
accuracy.


