From: Christian Hildner <christian.hildner@hob.de>
Date: Mon, 27 Feb 2006 08:15:13 +0000
Subject: Re: [patch 1/2] remove per-cpu ia64_phys_stacked_size_p8
Message-Id: <4402B511.3000801@hob.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <200602240233.k1O2Xeg05945@unix-os.sc.intel.com>
In-Reply-To: <200602240233.k1O2Xeg05945@unix-os.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Chen, Kenneth W schrieb:

>Christian Hildner wrote on Friday, February 24, 2006 2:08 AM
>  
>
>>self-modifing code isn't the straight forward way of programming. So 
>>wouldn't it be an idea to let the code crash instead of silently work 
>>with a potentially wrong number of registers here, if by any reason the 
>>patch mechanism doesn't work.
>>    
>>
>
>This argument is very biased.  A bug is a bug, regardless where the
>origin or through which mechanism.  Programming error like wrongly
>initialize a value has the same severity compare to patching wrong code.
>
True. However this isn't an argument against it. You might not even 
recognize that there is a bug. It might silently fail and maybe nobody 
would find it for years. With the break it would fail so you would be 
able to fix it immediately. And there is about no additional cost for 
using the break instruction.

>This argument is equally flawed.  If you don't have any trust in patching
>mechanism in previous argument, why would you trust that patch out a break
>instruction is going to be any better?
>
It is better because it would detect failure in the patch mechanism. Not 
more, not less.

Christian

