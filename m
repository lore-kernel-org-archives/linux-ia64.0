From: Peter Keilty <peter.keilty@hp.com>
Date: Fri, 27 Apr 2007 12:54:05 +0000
Subject: Re: [PATCH 1/3] ia64: convert to use clocksource code
Message-Id: <4631F26D.7080404@hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20070426202632.23343.54944.sendpatchset@rambler.zko.hp.com> <1177622301.6031.16.camel@localhost.localdomain>
In-Reply-To: <1177622301.6031.16.camel@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: john stultz <johnstul@us.ibm.com>
Cc: linux-ia64@vger.kernel.org, Eric Whitney <eric.whitney@hp.com>, linux-kernel@vger.kernel.org

john stultz wrote:

>On Thu, 2007-04-26 at 16:26 -0400, Peter Keilty wrote:
>  
>
>>From: Peter Keilty <peter.keilty@hp.com>
>>
>>Initial ia64 conversion to the generic timekeeping/clocksource code.
>>
>>Signed-off-by: Peter Keilty <peter.keilty@hp.com>
>>Signed-off-by: John Stultz <johnstul@us.ibm.com>
>>    
>>
>
>Peter,
>	Thanks so much for pushing this on! I suspect this patch needs to be
>updated a touch, as I'm not sure if it still compiles in light of recent
>changes...
>
>  
>
John,

You are correct, you need patch 3/3 for it to compile and run.
I did a patch to the orginal patch, thought that was correct thing to do.
But I can make a new patch 1 from the orginal of ours and my #3.
I would also make an update to the #2 patch from #3 for ntp correct change.
That would be just 2 patches then, the enable_ia64 and remove_interpolater.
What do you think?

>  
>
>>diff --git a/arch/ia64/kernel/cyclone.c b/arch/ia64/kernel/cyclone.c
>>index e00b215..280383b 100644
>>--- a/arch/ia64/kernel/cyclone.c
>>+++ b/arch/ia64/kernel/cyclone.c
>>@@ -3,6 +3,7 @@ #include <linux/smp.h>
>> #include <linux/time.h>
>> #include <linux/errno.h>
>> #include <linux/timex.h>
>>+#include <linux/clocksource.h>
>> #include <asm/io.h>
>>
>> /* IBM Summit (EXA) Cyclone counter code*/
>>@@ -18,13 +19,21 @@ void __init cyclone_setup(void)
>> 	use_cyclone = 1;
>> }
>>
>>+static void __iomem *cyclone_mc_ptr;
>>
>>-struct time_interpolator cyclone_interpolator = {
>>-	.source =	TIME_SOURCE_MMIO64,
>>-	.shift =	16,
>>-	.frequency =	CYCLONE_TIMER_FREQ,
>>-	.drift =	-100,
>>-	.mask =		(1LL << 40) - 1
>>+static cycle_t read_cyclone(void)
>>+{
>>+	return (cycle_t)readq((void __iomem *)cyclone_mc_ptr);
>>+}
>>+
>>+static struct clocksource clocksource_cyclone = {
>>+        .name           = "cyclone",
>>+        .rating         = 300,
>>+        .read           = read_cyclone,
>>+        .mask           = (1LL << 40) - 1,
>>    
>>
>
>Daniel Walker pointed out to me on IRC that CLOCKSOURCE_MASK() should
>probably be used here.
>
>  
>
>>+        .mult           = 0, /*to be caluclated*/
>>+        .shift          = 16,
>>+        .is_continuous  = 1,
>>    
>>
>
>.is_continuous no longer exists. 
>
>You want to use:
>.flags = CLOCK_SOURCE_IS_CONTINUOUS 
>
>This holds for all the clocksources introduced.
>
>
>thanks
>-john
>
>
>  
>
