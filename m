From: Sergei Shtylyov <sergei.shtylyov@gmail.com>
Date: Thu, 28 Jan 2021 08:00:29 +0000
Subject: Re: [PATCH 02/27] x86/syscalls: fix -Wmissing-prototypes warnings from COND_SYSCALL()
Message-Id: <605cea27-bd69-5b21-f285-2d3d0f6abd23@gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20210128005110.2613902-1-masahiroy@kernel.org>
 <20210128005110.2613902-3-masahiroy@kernel.org>
 <dd37a7f2-55e1-2e96-0c93-4a40980b8ef2@gmail.com>
In-Reply-To: <dd37a7f2-55e1-2e96-0c93-4a40980b8ef2@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
To: Masahiro Yamada <masahiroy@kernel.org>, linux-arch@vger.kernel.org, x86@kernel.org
Cc: linux-kbuild@vger.kernel.org, linux-kernel@vger.kernel.org, linux-alpha@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-ia64@vger.kernel.org, linux-m68k@lists.linux-m68k.org, linux-mips@vger.kernel.org, linux-parisc@vger.kernel.org, linux-sh@vger.kernel.org, linux-um@lists.infradead.org, linux-xtensa@linux-xtensa.org, linuxppc-dev@lists.ozlabs.org, sparclinux@vger.kernel.org

On 28.01.2021 10:59, Sergei Shtylyov wrote:

[...]
>> Building kernel/sys_ni.c with W=1 omits tons of -Wmissing-prototypes
> 
>     Emits?
> 
>> warnings.
>>
>> $ make W=1 kernel/sys_ni.o
>>    [ snip ]
>>    CC      kernel/sys_ni.o
>> In file included from kernel/sys_ni.c:10:
>> ./arch/x86/include/asm/syscall_wrapper.h:83:14: warning: no previous 
>> prototype for '__x64_sys_io_setup' [-Wmissing-prototypes]
>>     83 |  __weak long __##abi##_##name(const struct pt_regs *__unused) \
>>        |              ^~
>> ./arch/x86/include/asm/syscall_wrapper.h:100:2: note: in expansion of macro 
>> '__COND_SYSCALL'
>>    100 |  __COND_SYSCALL(x64, sys_##name)
>>        |  ^~~~~~~~~~~~~~
>> ./arch/x86/include/asm/syscall_wrapper.h:256:2: note: in expansion of macro 
>> '__X64_COND_SYSCALL'
>>    256 |  __X64_COND_SYSCALL(name)     \
>>        |  ^~~~~~~~~~~~~~~~~~
>> kernel/sys_ni.c:39:1: note: in expansion of macro 'COND_SYSCALL'
>>     39 | COND_SYSCALL(io_setup);
>>        | ^~~~~~~~~~~~
>> ./arch/x86/include/asm/syscall_wrapper.h:83:14: warning: no previous 
>> prototype for '__ia32_sys_io_setup' [-Wmissing-prototypes]
>>     83 |  __weak long __##abi##_##name(const struct pt_regs *__unused) \
>>        |              ^~
>> ./arch/x86/include/asm/syscall_wrapper.h:120:2: note: in expansion of macro 
>> '__COND_SYSCALL'
>>    120 |  __COND_SYSCALL(ia32, sys_##name)
>>        |  ^~~~~~~~~~~~~~
>> ./arch/x86/include/asm/syscall_wrapper.h:257:2: note: in expansion of macro 
>> '__IA32_COND_SYSCALL'
>>    257 |  __IA32_COND_SYSCALL(name)
>>        |  ^~~~~~~~~~~~~~~~~~~
>> kernel/sys_ni.c:39:1: note: in expansion of macro 'COND_SYSCALL'
>>     39 | COND_SYSCALL(io_setup);
>>        | ^~~~~~~~~~~~
>>    ...
>>
>> __SYS_STUB0() and __SYS_STUBx() defined a few lines above have forward
>> declarations. Let's do likewise for __COND_SYSCALL() to fix the
>> warnings.
>>
>> Signed-off-by: Masahiro Yamada <masahiroy@kernel.org>
>> ---
>>
>>   arch/x86/include/asm/syscall_wrapper.h | 1 +
>>   1 file changed, 1 insertion(+)
>>
>> diff --git a/arch/x86/include/asm/syscall_wrapper.h 
>> b/arch/x86/include/asm/syscall_wrapper.h
>> index a84333adeef2..80c08c7d5e72 100644
>> --- a/arch/x86/include/asm/syscall_wrapper.h
>> +++ b/arch/x86/include/asm/syscall_wrapper.h
>> @@ -80,6 +80,7 @@ extern long __ia32_sys_ni_syscall(const struct pt_regs 
>> *regs);
>>       }
>>   #define __COND_SYSCALL(abi, name)                    \
>> +    __weak long __##abi##_##name(const struct pt_regs *__unused);    \
>>       __weak long __##abi##_##name(const struct pt_regs *__unused)    \
> 
>     Aren't these two lines identical?

     Ah, got it! :-)

[...]

MBR, Sergei
