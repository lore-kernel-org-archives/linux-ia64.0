From: Jeremy Fitzhardinge <jeremy@goop.org>
Date: Fri, 18 Jul 2008 04:51:59 +0000
Subject: Re: [PATCH 24/29] ia64/pv_ops/xen: implement xen pv_time_ops.
Message-Id: <4880216F.6040900@goop.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <12162606623288-git-send-email-yamahata@valinux.co.jp>
In-Reply-To: <12162606623288-git-send-email-yamahata@valinux.co.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Isaku Yamahata wrote:
> On Thu, Jul 17, 2008 at 07:21:37AM -0700, Jeremy Fitzhardinge wrote:
>   
>> Isaku Yamahata wrote:
>>     
>>> I had explained about that.
>>> I had considered that option. However my conclusion is not share 
>>> he implementation because xen/ia64 timer interrupt isn't
>>> paravirtualized with VCPUOP_xxx hypercall. But xen/ia64 emulates
>>> ar.itm register. (ar.itm is interval time match register which triggers
>>> interrupt when interval time counter becomes same value)
>>>
>>> Since timer interruption is virtualized differently on xen/ia64,
>>> the different implementation is a natural consequence.
>>>       
>> OK, that means the clockevent and clocksource part would be different.  
>> But the runstate accounting should still be the same, no?
>>     
>
> Unfortunately no. At first I had hoped so, but no.
> Looking consider_steal_time() which implements ia64 steal time
> accounting, I have no idea to share code cleanly with x86 steal time
> accounting, do_stolen_accounting().
>   

So, my understanding from looking at your patch that the itc is somewhat 
like the x86 tsc, in that it's not (necessarily) synchronized between 
cpus.  But unlike the tsc, the itc is always in nanoseconds, but you 
don't get information from Xen about the current physical cpu's offset 
from absolute system time.  And that means you have the (rather dubious 
looking) comparisons to test for large jumps in the itc which you try to 
ignore.

If you had some way to determine the current itc offset, then you could 
easily have an itc-based clocksource_read(), which would allow you to 
use the x86 code for stolen time accounting.  I don't know how easy that 
would be to do.

    J
