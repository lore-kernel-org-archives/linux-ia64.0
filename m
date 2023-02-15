From: =?UTF-8?Q?Philippe_Mathieu-Daud=c3=a9?= <philmd@linaro.org>
Date: Wed, 15 Feb 2023 08:29:20 +0000
Subject: Re: [PATCH v2 09/24] mips/cpu: Expose play_dead()'s prototype definition
Message-Id: <c56dc4b9-035d-7773-ecb2-0e1ac6af7abc@linaro.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <cover.1676358308.git.jpoimboe@kernel.org>
 <39835bc75af2e812fce56400533cb2ab41bcf0e2.1676358308.git.jpoimboe@kernel.org>
 <080a5ccb-7fa0-1a75-538f-a09dc146fc4e@linaro.org>
 <20230214181101.3a2tscbmwdnwbqpu@treble>
In-Reply-To: <20230214181101.3a2tscbmwdnwbqpu@treble>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
To: Josh Poimboeuf <jpoimboe@kernel.org>
Cc: linux-kernel@vger.kernel.org, jgross@suse.com, richard.henderson@linaro.org, ink@jurassic.park.msu.ru, mattst88@gmail.com, linux-alpha@vger.kernel.org, linux@armlinux.org.uk, linux-arm-kernel@lists.infradead.org, catalin.marinas@arm.com, will@kernel.org, guoren@kernel.org, linux-csky@vger.kernel.org, linux-ia64@vger.kernel.org, chenhuacai@kernel.org, kernel@xen0n.name, loongarch@lists.linux.dev, f.fainelli@gmail.com, bcm-kernel-feedback-list@broadcom.com, tsbogend@alpha.franken.de, linux-mips@vger.kernel.org, jiaxun.yang@flygoat.com, mpe@ellerman.id.au, npiggin@gmail.com, christophe.leroy@csgroup.eu, linuxppc-dev@lists.ozlabs.org, ysato@users.sourceforge.jp, dalias@libc.org, linux-sh@vger.kernel.org, davem@davemloft.net, sparclinux@vger.kernel.org, tglx@linutronix.de, mingo@redhat.com, bp@alien8.de, dave.hansen@linux.intel.com, x86@kernel.org, hpa@zytor.com, chris@zankel.net, jcmvbkbc@gmail.com, linux-xtensa@linux-xtensa.org, peterz@infradead.org, juri.lelli@redhat.com, vincent.guittot@linaro.org, dietmar.eggemann@arm.com, rostedt@goodmis.org, bsegall@google.com, mgorman@suse.de, bristot@redhat.com, vschneid@redhat.com, paulmck@kernel.org

On 14/2/23 19:11, Josh Poimboeuf wrote:
> On Tue, Feb 14, 2023 at 08:46:41AM +0100, Philippe Mathieu-Daudé wrote:
>> Hi Josh,
>>
>> On 14/2/23 08:05, Josh Poimboeuf wrote:
>>> Include <asm/smp.h> to make sure play_dead() matches its prototype going
>>> forward.
>>>
>>> Acked-by: Florian Fainelli <f.fainelli@gmail.com>
>>> Signed-off-by: Josh Poimboeuf <jpoimboe@kernel.org>
>>> ---
>>>    arch/mips/kernel/smp-bmips.c | 1 +
>>>    1 file changed, 1 insertion(+)
>>>
>>> diff --git a/arch/mips/kernel/smp-bmips.c b/arch/mips/kernel/smp-bmips.c
>>> index f5d7bfa3472a..df9158e8329d 100644
>>> --- a/arch/mips/kernel/smp-bmips.c
>>> +++ b/arch/mips/kernel/smp-bmips.c
>>> @@ -38,6 +38,7 @@
>>>    #include <asm/traps.h>
>>>    #include <asm/barrier.h>
>>>    #include <asm/cpu-features.h>
>>> +#include <asm/smp.h>
>>
>> What about the other implementations?
>>
>> $ git grep -L asm/smp.h $(git grep -wlF 'play_dead(void)' arch/mips)
>> arch/mips/cavium-octeon/smp.c
>> arch/mips/kernel/smp-bmips.c
>> arch/mips/kernel/smp-cps.c
>> arch/mips/loongson64/smp.c
> 
> Indeed.  I really wish we had -Wmissing-prototypes.
> 
> I'll squash this in:
> 
> diff --git a/arch/mips/cavium-octeon/smp.c b/arch/mips/cavium-octeon/smp.c
> index 89954f5f87fb..4212584e6efa 100644
> --- a/arch/mips/cavium-octeon/smp.c
> +++ b/arch/mips/cavium-octeon/smp.c
> @@ -20,6 +20,7 @@
>   #include <asm/mmu_context.h>
>   #include <asm/time.h>
>   #include <asm/setup.h>
> +#include <asm/smp.h>
>   
>   #include <asm/octeon/octeon.h>
>   
> diff --git a/arch/mips/kernel/smp-cps.c b/arch/mips/kernel/smp-cps.c
> index bcd6a944b839..6d69a9ba8167 100644
> --- a/arch/mips/kernel/smp-cps.c
> +++ b/arch/mips/kernel/smp-cps.c
> @@ -20,6 +20,7 @@
>   #include <asm/mipsregs.h>
>   #include <asm/pm-cps.h>
>   #include <asm/r4kcache.h>
> +#include <asm/smp.h>
>   #include <asm/smp-cps.h>
>   #include <asm/time.h>
>   #include <asm/uasm.h>
> diff --git a/arch/mips/loongson64/smp.c b/arch/mips/loongson64/smp.c
> index c81c2bd07c62..df8d789ede3c 100644
> --- a/arch/mips/loongson64/smp.c
> +++ b/arch/mips/loongson64/smp.c
> @@ -14,6 +14,7 @@
>   #include <linux/cpufreq.h>
>   #include <linux/kexec.h>
>   #include <asm/processor.h>
> +#include <asm/smp.h>
>   #include <asm/time.h>
>   #include <asm/tlbflush.h>
>   #include <asm/cacheflush.h>

Reviewed-by: Philippe Mathieu-Daudé <philmd@linaro.org>

Thanks.
