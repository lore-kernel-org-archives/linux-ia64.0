From: Christian Hildner <christian.hildner@hob.de>
Date: Wed, 02 Jun 2004 05:56:49 +0000
Subject: Re: Real time clock on ia64 platforms
Message-Id: <40BD6C21.5080008@hob.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <40BC3558.7040606@hob.de>
In-Reply-To: <40BC3558.7040606@hob.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Matthew Wilcox schrieb:

>On Tue, Jun 01, 2004 at 09:50:48AM +0200, Christian Hildner wrote:
>  
>
>>someone may know what kind of RTC device the ia64 platforms (HP ZX 6000 
>>+ i2000) use. I want to access it directly, without using EFI calls.
>>    
>>
>
>It's probably different on each of them.  Why do you want to access it
>without going through firmware?
>
It's just because I need rtc information in an environment where no EFI 
calls are possible. I am aware of the non-portability of doing so. But 
there is no other way.

Christian

