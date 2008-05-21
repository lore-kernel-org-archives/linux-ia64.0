From: Avi Kivity <avi@qumranet.com>
Date: Wed, 21 May 2008 10:05:14 +0000
Subject: Re: [patch] fix zero extending for mmio ld1/2/4 emulation in KVM
Message-Id: <4833F3DA.5090002@qumranet.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <4832A0A6.8050800@sgi.com>
In-Reply-To: <4832A0A6.8050800@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Zhang, Xiantao wrote:
> Jes Sorensen wrote:
>   
>> Matthew Chapman wrote:
>>     
>>> Jes,
>>>
>>> Glad you tracked it down.  Can I suggest rather than using memcpy, a
>>> more efficient way might be something like...
>>>
>>> #define ZERO_EXTEND(x,bits) ((x) & (~0UL >> (64-(bits))))
>>>
>>> *dest = ZERO_EXTEND(p->u.ioreq.data, 8*s);
>>>       
>> Much nicer indeed!
>>
>> Here's a pretty version - Tony will you apply this one instead.
>>     
> Hi, Jes
>     Good catch!!   Since this is a key fix for 2.6.26, Avi or Tony may
> help to push the fix into upstream.  :-)
>   

Applied, and also queued for 2.6.26.


-- 
error compiling committee.c: too many arguments to function

