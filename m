From: WANG Xuerui <kernel@xen0n.name>
Date: Tue, 14 Feb 2023 08:59:46 +0000
Subject: Re: [PATCH v3 10/24] sparc: Remove COMMAND_LINE_SIZE from uapi
Message-Id: <f3db61bb-5c89-2724-769f-9d606f587f92@xen0n.name>
List-Id: <linux-ia64.vger.kernel.org>
References: <20230214074925.228106-1-alexghiti@rivosinc.com>
 <20230214074925.228106-11-alexghiti@rivosinc.com>
 <017f0b40-8021-8b3b-24d2-c70661b6b292@omp.ru>
In-Reply-To: <017f0b40-8021-8b3b-24d2-c70661b6b292@omp.ru>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Sergey Shtylyov <s.shtylyov@omp.ru>, Alexandre Ghiti <alexghiti@rivosinc.com>, Jonathan Corbet <corbet@lwn.net>, Richard Henderson <richard.henderson@linaro.org>, Ivan Kokshaysky <ink@jurassic.park.msu.ru>, Matt Turner <mattst88@gmail.com>, Vineet Gupta <vgupta@kernel.org>, Russell King <linux@armlinux.org.uk>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will@kernel.org>, Huacai Chen <chenhuacai@kernel.org>, Geert Uytterhoeven <geert@linux-m68k.org>, Michal Simek <monstr@monstr.eu>, Thomas Bogendoerfer <tsbogend@alpha.franken.de>, "James E . J . Bottomley" <James.Bottomley@HansenPartnership.com>, Helge Deller <deller@gmx.de>, Michael Ellerman <mpe@ellerman.id.au>, Nicholas Piggin <npiggin@gmail.com>, Christophe Leroy <christophe.leroy@csgroup.eu>, Paul Walmsley <paul.walmsley@sifive.com>, Palmer Dabbelt <palmer@dabbelt.com>, Albert Ou <aou@eecs.berkeley.edu>, Heiko Carstens <hca@linux.ibm.com>, Vasily Gorbik <gor@linux.ibm.com>, Alexander Gordeev <agordeev@linux.ibm.com>, Christian Borntraeger <borntraeger@linux.ibm.com>, Sven Schnelle <svens@linux.ibm.com>, Yoshinori Sato <ysato@users.sourceforge.jp>, Rich Felker <dalias@libc.org>, "David S . Miller" <davem@davemloft.net>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, Dave Hansen <dave.hansen@linux.intel.com>, x86@kernel.org, "H . Peter Anvin" <hpa@zytor.com>, Chris Zankel <chris@zankel.net>, Max Filippov <jcmvbkbc@gmail.com>, Arnd Bergmann <arnd@arndb.de>, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-alpha@vger.kernel.org, linux-snps-arc@lists.infradead.org, linux-arm-kernel@lists.infradead.org, linux-ia64@vger.kernel.org, loongarch@lists.linux.dev, linux-m68k@lists.linux-m68k.org, linux-mips@vger.kernel.org, linux-parisc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-riscv@lists.infradead.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, linux-xtensa@linux-xtensa.org, linux-arch@vger.kernel.org
Cc: Palmer Dabbelt <palmer@rivosinc.com>

On 2023/2/14 16:50, Sergey Shtylyov wrote:
> On 2/14/23 10:49 AM, Alexandre Ghiti wrote:
> 
>> From: Palmer Dabbelt <palmer@rivosinc.com>
>>
>> As far as I can tell this is not used by userspace and thus should not
>> be part of the user-visible API.
>>
>> Signed-off-by: Palmer Dabbelt <palmer@rivosinc.com>
>> ---
>>   arch/sparc/include/asm/setup.h      | 6 +++++-
>>   arch/sparc/include/uapi/asm/setup.h | 7 -------
>>   2 files changed, 5 insertions(+), 8 deletions(-)
>>
>> diff --git a/arch/sparc/include/asm/setup.h b/arch/sparc/include/asm/setup.h
>> index 72205684e51e..d1384ed92547 100644
>> --- a/arch/sparc/include/asm/setup.h
>> +++ b/arch/sparc/include/asm/setup.h
>> @@ -7,7 +7,11 @@
>>   
>>   #include <linux/interrupt.h>
>>   
>> -#include <uapi/asm/setup.h>
>> +#if defined(__sparc__) && defined(__arch64__)
> 
>     Mhm, I don't think these two can be #define'd simulaneously...

I believe it's just a SPARC-ism [1] [2] that may look strange and be 
easily confused for __aarch64__ (notice the extra 'a')...

[1]: 
https://github.com/gcc-mirror/gcc/blob/basepoints/gcc-12/gcc/config/sparc/sparc.h#L301
[2]: 
https://github.com/llvm/llvm-project/blob/llvmorg-17-init/clang/lib/Basic/Targets/Sparc.cpp#L241

-- 
WANG "xen0n" Xuerui

Linux/LoongArch mailing list: https://lore.kernel.org/loongarch/
