From: Jens Axboe <axboe@kernel.dk>
Date: Thu, 28 Jan 2021 22:56:07 +0000
Subject: Re: [PATCH] ia64: add support for TIF_NOTIFY_SIGNAL
Message-Id: <e9788776-d309-3936-aa11-78906d90c3c8@kernel.dk>
List-Id: <linux-ia64.vger.kernel.org>
References: <d3a2aa1e-0fae-1d3f-519f-d32adc608c38@kernel.dk>
In-Reply-To: <d3a2aa1e-0fae-1d3f-519f-d32adc608c38@kernel.dk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On 1/28/21 3:51 PM, John Paul Adrian Glaubitz wrote:
> On 1/28/21 11:42 PM, Jens Axboe wrote:
>>> I just tried Linus' current tree (ge5ff2cb9cf67) and the problem still persists.
>>
>> Funky... Can you see if this helps?
>>
>> diff --git a/arch/ia64/kernel/signal.c b/arch/ia64/kernel/signal.c
>> index e67b22fc3c60..7de57ace4799 100644
>> --- a/arch/ia64/kernel/signal.c
>> +++ b/arch/ia64/kernel/signal.c
>> @@ -358,9 +358,6 @@ ia64_do_signal (struct sigscratch *scr, long in_syscall)
>>  			 */
>>  			restart = 0;
>>  
>> -		if (ksig.sig <= 0)
>> -			break;
>> -
>>  		if (unlikely(restart)) {
>>  			switch (errno) {
>>  			case ERESTART_RESTARTBLOCK:
>> @@ -381,6 +378,9 @@ ia64_do_signal (struct sigscratch *scr, long in_syscall)
>>  			}
>>  		}
>>  
>> +		if (ksig.sig <= 0)
>> +			break;
>> +
>>  		/*
>>  		 * Whee!  Actually deliver the signal.  If the delivery failed, we need to
>>  		 * continue to iterate in this loop so we can deliver the SIGSEGV...
> 
> This one doesn't help. Will try the other in a minute.

Also looks like you might need to add a:

	ksig.sig = 0;

right above get_signal(), just in case. For the 2nd patch, I mean. But thanks
for testing, interested if the other one will do it...

-- 
Jens Axboe
