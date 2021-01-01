From: Jens Axboe <axboe@kernel.dk>
Date: Fri, 01 Jan 2021 18:22:37 +0000
Subject: Re: [PATCH] sh: add support for TIF_NOTIFY_SIGNAL
Message-Id: <4acdfb5b-842f-aba4-0f6c-20b4795ded35@kernel.dk>
List-Id: <linux-ia64.vger.kernel.org>
References: <5fcc82b4-89ae-3bca-10ab-6ad933565cee@kernel.dk>
 <ae29ab73-ee7a-2bb7-3fd8-3037f40c1cbd@kernel.dk>
 <5611bde9-67e7-6ff6-defc-9b02ea830fac@physik.fu-berlin.de>
 <9ea14eb3-d698-5499-ba4c-c6a3c35cd8d4@kernel.dk>
 <47f79645-53b7-b11c-167a-f5721b53df02@physik.fu-berlin.de>
 <9d9acec6-1e8c-2d68-5dfa-d58c11cf5cc4@kernel.dk>
 <070780c4-445e-6373-c8f4-1c72d0f3b4e0@physik.fu-berlin.de>
 <1047f3e5-4599-c34f-3176-9f41d2e1246b@kernel.dk>
 <31b34cfc-8d6e-d3b4-e29f-1ec485f5b368@physik.fu-berlin.de>
 <23bf4423-0987-c445-d5cd-1922e1e40820@kernel.dk>
 <f95539e9-506b-c4d9-2861-f288e2d021df@physik.fu-berlin.de>
 <10752e73-ca2a-9ea7-4aa6-35e366e36fb0@kernel.dk>
 <b16ed393-e2bf-deca-d0d9-614d24ee6406@physik.fu-berlin.de>
In-Reply-To: <b16ed393-e2bf-deca-d0d9-614d24ee6406@physik.fu-berlin.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: John Paul Adrian Glaubitz <glaubitz@physik.fu-berlin.de>
Cc: linux-sh@vger.kernel.org, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>

On 1/1/21 11:16 AM, John Paul Adrian Glaubitz wrote:
> On 1/1/21 4:35 PM, Jens Axboe wrote:> It's supposed to finish very quickly:
>>
>> axboe@p1 ~> time ./socket-rw                                                             0.000s
>>
>> ________________________________________________________
>> Executed in    1.10 millis    fish           external 
>>    usr time  888.00 micros  278.00 micros  610.00 micros 
>>    sys time   35.00 micros   35.00 micros    0.00 micros 
>>
>> If it doesn't, can you try:
>>
>> # echo 1 > /sys/kernel/debug/tracing/events/io_uring/enable
>>
>> Then run the socket-rw app, and then do:
>>
>> # cat /sys/kernel/debug/tracing/trace
>>
>> and send that output? Might also be useful to include the strace
>> of the socket-rw just in case, so maybe run it ala
>>
>> strace -o foo ./socket-rw
>>
>> and include foo in the reply as well.
> 
> Odd, I just ran it through strace and it exited immediately:

That looks correct, it sets up a ring, issues and waits for two
requests. Both of those requests require TWA_SIGNAL processing.

-- 
Jens Axboe
