From: Christian Hildner <christian.hildner@hob.de>
Date: Wed, 02 Jun 2004 06:26:53 +0000
Subject: Re: Real time clock on ia64 platforms
Message-Id: <40BD732D.6030709@hob.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <40BC3558.7040606@hob.de>
In-Reply-To: <40BC3558.7040606@hob.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Alex Williamson schrieb:

>On Tue, 2004-06-01 at 01:50, Christian Hildner wrote:
>  
>
>>Hi,
>>
>>someone may know what kind of RTC device the ia64 platforms (HP ZX 6000 
>>+ i2000) use. I want to access it directly, without using EFI calls.
>>    
>>
>
>   This is strongly not recommended.  On HP chipset boxes, the devices
>are only designed to be accessed via the EFI calls (and yes, EFI
>firmware can and does work around bugs in the RTC).  There's also no
>architected way to find the real RTC in the address map.
>
So the only chance to access the rtc directly is to do it the same way 
the firmware does. Since the firmware is that hardware specific it does 
not need to "find" it because the firmware already knows where the rtc 
is and how to access it. If the rtc is not mapped in the conventional 
port address map, how does the firmware access it? Is there a 
firmware-only accessible io memory map or is it done with machine 
specific registers (msr)?

>  Why do you
>need to poke it directly?
>
Because I need to call it from an environment, where no EFI calls are 
possible. I know that the solution is absolutely not portable in any way 
and in common it is bad doing that way but in that special case there is 
no other way to go. And  the portability is given at another layer on 
top of it.

Christian

>	Alex
>

