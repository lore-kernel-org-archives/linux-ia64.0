From: George Anzinger <george@mvista.com>
Date: Wed, 13 Oct 2004 17:25:09 +0000
Subject: Re: Periodic posix timer support broke between 2.6.9-rc1 and 2.6.9-rc1-bk17
Message-Id: <416D64F5.4000307@mvista.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.58.0410130902490.9272@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.58.0410130902490.9272@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Christoph Lameter wrote:
> On Tue, 12 Oct 2004, George Anzinger wrote:
> 
> 
>>Christoph Lameter wrote:
>>
>>>I ran some test programs and discovered that the periodic timer support
>>>is broken. The timer is triggered once and then never again. Single shot
>>>timers work fine. 2.6.9-rc1 is fine. The first kernel that I tested where
>>>I noticed the breakage was 2.6.9-rc1-bk17. 2.6.9-rc2 and following all
>>>cannot do periodic timer signals.
>>>
>>>I looked through the changelog but I cannot see anything that would cause
>>>the problem. Roland's patch surely could not have done this.
>>>
>>>Will try to track this down further, time permitting...
>>
>>The most likely thing would be failure to do the call back from the signal
>>delivery code.
> 
> 
> The problem is IA64 arch specific. Works fine on i386.

And I repeat:
The most likely thing would be failure to do the call back from the signal
delivery code.

> 

-- 
George Anzinger   george@mvista.com
High-res-timers:  http://sourceforge.net/projects/high-res-timers/
Preemption patch: http://www.kernel.org/pub/linux/kernel/people/rml

