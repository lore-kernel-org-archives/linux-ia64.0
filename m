From: george anzinger <george@mvista.com>
Date: Tue, 18 Mar 2003 23:21:57 +0000
Subject: [Linux-ia64] Re: POSIX timers interface for IA64
Message-Id: <marc-linux-ia64-105590723705266@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709806084@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709806084@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

David Mosberger wrote:
>>>>>>On Fri, 07 Mar 2003 14:40:04 +0100, Eric Piel <Eric.Piel@Bull.Net> said:
> 
> 
>   Eric> Hello, Here is a patch to have the POSIX timer interface
>   Eric> completly integrated in ia64 (2.5.64). The programs in
>   Eric> userland can now access the siginfo structure. With that patch
>   Eric> the test programs of the high resolution timers pass without
>   Eric> error but one which seems to also be triggered on ix86:
>   Eric> nanosleeps too short.

When we get the cascade stuff fixed :), we can address this issue.  On 
the ix86 the too short sleep is caused by adding less than 1/HZ to the 
wall clock each timer interrupt.  You might want to see what value 
your platform adds.  I intend to address this soon, but will need to 
check with the community about the correct fix.

As it now stands, CLOCK_MONOTONIC ticks at a different rate than 
CLOCK_REALTIME.  What to do, Oh what to do...

-g
> 
>   Eric> I did the same modifications to the ia32 support but I wasn't
>   Eric> able to test them.
> 
> I applied this patch in my (ia64) tree.
> 
> Thanks!
> 
> 	--david
> 
> 
> -------------------------------------------------------
> This SF.net email is sponsored by:Crypto Challenge is now open! 
> Get cracking and register here for some mind boggling fun and 
> the chance of winning an Apple iPod:
> http://ads.sourceforge.net/cgi-bin/redirect.pl?thaw0031en
> to unsubscribe: http://lists.sourceforge.net/lists/listinfo/high-res-timers-discourse
> High-res-timers-discourse mailing list
> High-res-timers-discourse@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/high-res-timers-discourse
> 
> 

-- 
George Anzinger   george@mvista.com
High-res-timers:  http://sourceforge.net/projects/high-res-timers/
Preemption patch: http://www.kernel.org/pub/linux/kernel/people/rml


