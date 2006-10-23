From: Martin Peschke <mp3@de.ibm.com>
Date: Mon, 23 Oct 2006 22:04:37 +0000
Subject: Re: printk_clock() patch breaks sn2 arch
Message-Id: <453D3C75.5070808@de.ibm.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.64.0610231354470.32322@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.64.0610231354470.32322@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Christoph Lameter wrote:
> On Mon, 23 Oct 2006, Martin Peschke wrote:
> 
>> I don't see how I could have broken it, as my patch just renames
>> ia64_printk_clock() to ia64_timetamp_clock():
>> +++ a/arch/ia64/sn/kernel/setup.c
>> @@ -66,7 +66,7 @@ extern unsigned long last_time_offset;
>>  extern void (*ia64_mark_idle) (int);
>>  extern void snidle(int);
>>  extern unsigned char acpi_kbd_controller_present;
>> -extern unsigned long long (*ia64_printk_clock)(void);
>> +extern unsigned long long (*ia64_timestamp_clock)(void);
> 
> Hmmm... This piece of the patch seems to have been dropped. I guess 
> the best solution is to make sure that Andrew has your complete patch in 
> his tree and forget about my patch:
> 
> 2.6.19-rc2-mm2 has:
> 
> extern void (*ia64_mark_idle) (int);
> extern void snidle(int);
> extern unsigned long long (*ia64_printk_clock)(void);
> 
> unsigned long sn_rtc_cycles_per_second;
> EXPORT_SYMBOL(sn_rtc_cycles_per_second);
> 

Mmh, you are right the extern declaration was dropped from setup.c,
ia64 folks to introduce a proper extern declaration? Wondering why ;)

http://marc.theaimsgroup.com/?l=linux-kernel&m6137801232337&w=2

