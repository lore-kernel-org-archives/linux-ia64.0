From: James Morse <james.morse@arm.com>
Date: Wed, 18 Jan 2023 11:44:54 +0000
Subject: Re: [PATCH] ia64: Fix build error due to switch case label appearing next to declaration
Message-Id: <99b295ed-7157-0c95-cafb-9cf8afdf41f2@arm.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20230117151632.393836-1-james.morse@arm.com>
 <20230117193109.5650fd6f@nz>
In-Reply-To: <20230117193109.5650fd6f@nz>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Sergei Trofimovich <slyich@gmail.com>
Cc: linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, matoro <matoro_mailinglist_kernel@matoro.tk>, =?UTF-8?Q?=c3=89meric_Maschino?= <emeric.maschino@gmail.com>, Andrew Morton <akpm@linux-foundation.org>

Hi Sergei,

On 17/01/2023 19:31, Sergei Trofimovich wrote:
> On Tue, 17 Jan 2023 15:16:32 +0000
> James Morse <james.morse@arm.com> wrote:
> 
>> Since commit aa06a9bd8533 ("ia64: fix clock_getres(CLOCK_MONOTONIC) to
>> report ITC frequency"), gcc 10.1.0 fails to build ia64 with the gnomic:
>> | ../arch/ia64/kernel/sys_ia64.c: In function 'ia64_clock_getres':
>> | ../arch/ia64/kernel/sys_ia64.c:189:3: error: a label can only be part of a statement and a declaration is not a statement
>> |   189 |   s64 tick_ns = DIV_ROUND_UP(NSEC_PER_SEC, local_cpu_data->itc_freq);
>>
>> This line appears immediately after a case label in a switch.
>>
>> Move the declarations out of the case, to the top of the function.
>>
>> Fixes: aa06a9bd8533 ("ia64: fix clock_getres(CLOCK_MONOTONIC) to report ITC frequency")
>> Signed-off-by: James Morse <james.morse@arm.com>

> Out of curiosity what compiler version behaves like that? I think I and
> matoro build-/run-tested it on gcc-12 and maybe gcc-11.

| # ia64-linux-gcc --version
| ia64-linux-gcc (GCC) 10.1.0
| Copyright (C) 2020 Free Software Foundation, Inc.
| This is free software; see the source for copying conditions.  There is NO
| warranty; not even for MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

The toolchain originally came from https://mirrors.edge.kernel.org/pub/tools/crosstool/

The really odd thing I'm doing is cross compiling for ia64 on arm64 ... but I wouldn't
have thought the toolchain configuration was any different.


> Thank you!
> 
> Reviewed-by: Sergei Trofimovich <slyich@gmail.com>


Thanks,

James
