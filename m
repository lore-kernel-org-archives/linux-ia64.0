From: Michael Jeanson <mjeanson@efficios.com>
Date: Wed, 14 Dec 2022 20:26:27 +0000
Subject: Re: [RFC PATCH] Syscall tracing on PPC64_ELF_ABI_V1 without KALLSYMS_ALL
Message-Id: <a6e99b31-5719-5f21-3c4f-836f809e893e@efficios.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20221212212159.3435046-1-mjeanson@efficios.com>
 <39c53bd1-432f-15f6-4cbd-b8551fc261cf@csgroup.eu>
In-Reply-To: <39c53bd1-432f-15f6-4cbd-b8551fc261cf@csgroup.eu>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
To: Christophe Leroy <christophe.leroy@csgroup.eu>, "linuxppc-dev@lists.ozlabs.org" <linuxppc-dev@lists.ozlabs.org>
Cc: Michael Ellerman <mpe@ellerman.id.au>, Mathieu Desnoyers <mathieu.desnoyers@efficios.com>, Arnd Bergmann <arnd@arndb.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Steven Rostedt <rostedt@goodmis.org>, Masami Hiramatsu <mhiramat@kernel.org>, linux-arch <linux-arch@vger.kernel.org>, "open list:PARISC ARCHITECTURE" <linux-parisc@vger.kernel.org>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>

On 2022-12-13 02:29, Christophe Leroy wrote:
> The changes are absolutely not specific to powerpc. You should adjust
> the subject accordingly, and copy linux-arch and tracing and probably
> also ia64 and parisc.

I was hoping to get feedback from the PPC maintainers before posting something 
more widely. I'll send an updated patch which addresses your comments.

Thanks.

> 
> Le 12/12/2022 à 22:21, Michael Jeanson a écrit :
>> In ad050d2390fccb22aa3e6f65e11757ce7a5a7ca5 we fixed ftrace syscall
>> tracing on PPC64_ELF_ABI_V1 by looking for the non-dot prefixed symbol
>> of a syscall.
> 
> Should be written as:
> 
> Commit ad050d2390fc ("powerpc/ftrace: fix syscall tracing on
> PPC64_ELF_ABI_V1") fixed ....
> 
> 
>>
>> Ftrace uses kallsyms to locate syscall symbols and those non-dot
>> prefixed symbols reside in a separate '.opd' section which is not
>> included by kallsyms.
>>
>> So we either need to have FTRACE_SYSCALLS select KALLSYMS_ALL on
>> PPC64_ELF_ABI_V1 or add the '.opd' section symbols to kallsyms.
>>
>> This patch does the minimum to achieve the latter, it's tested on a
>> corenet64_smp_defconfig with KALLSYMS_ALL turned off.
>>
>> I'm unsure which of the alternatives would be better.
>>
>> ---
>> In 'kernel/module/kallsyms.c' the 'is_core_symbol' function might also
>> require some tweaking to make all opd symbols available to kallsyms but
>> that doesn't impact ftrace syscall tracing.
>>
>> Cc: Michael Ellerman <mpe@ellerman.id.au>
>> Cc: Christophe Leroy <christophe.leroy@csgroup.eu>
>> Cc: Mathieu Desnoyers <mathieu.desnoyers@efficios.com>
>> Signed-off-by: Michael Jeanson <mjeanson@efficios.com>
>> ---
>>    include/asm-generic/sections.h | 14 ++++++++++++++
>>    include/linux/kallsyms.h       |  3 +++
>>    kernel/kallsyms.c              |  2 ++
>>    scripts/kallsyms.c             |  1 +
>>    4 files changed, 20 insertions(+)
>>
>> diff --git a/include/asm-generic/sections.h b/include/asm-generic/sections.h
>> index db13bb620f52..1410566957e5 100644
>> --- a/include/asm-generic/sections.h
>> +++ b/include/asm-generic/sections.h
>> @@ -180,6 +180,20 @@ static inline bool is_kernel_rodata(unsigned long addr)
>>    	       addr < (unsigned long)__end_rodata;
>>    }
>>    
>> +/**
>> + * is_kernel_opd - checks if the pointer address is located in the
>> + *                 .opd section
>> + *
>> + * @addr: address to check
>> + *
>> + * Returns: true if the address is located in .opd, false otherwise.
>> + */
>> +static inline bool is_kernel_opd(unsigned long addr)
>> +{
> 
> I would add a check of CONFIG_HAVE_FUNCTION_DESCRIPTORS:
> 
> 	if (!IS_ENABLED(CONFIG_HAVE_FUNCTION_DESCRIPTORS))
> 		return false;
> 
>> +	return addr >= (unsigned long)__start_opd &&
>> +	       addr < (unsigned long)__end_opd;
>> +}
>> +
>>    /**
>>     * is_kernel_inittext - checks if the pointer address is located in the
>>     *                      .init.text section
>> diff --git a/include/linux/kallsyms.h b/include/linux/kallsyms.h
>> index 649faac31ddb..9bfb4d8d41a5 100644
>> --- a/include/linux/kallsyms.h
>> +++ b/include/linux/kallsyms.h
>> @@ -43,6 +43,9 @@ static inline int is_ksym_addr(unsigned long addr)
>>    	if (IS_ENABLED(CONFIG_KALLSYMS_ALL))
>>    		return is_kernel(addr);
>>    
>> +	if (IS_ENABLED(CONFIG_HAVE_FUNCTION_DESCRIPTORS))
>> +		return is_kernel_text(addr) || is_kernel_inittext(addr) || is_kernel_opd(addr);
>> +
> 
> With the check inside is_kernel_opd(), you can make it simpler:
> 
> 	return is_kernel_text(addr) || is_kernel_inittext(addr) ||
> is_kernel_opd(addr);
> 
>>    	return is_kernel_text(addr) || is_kernel_inittext(addr);
>>    }
>>    
>> diff --git a/kernel/kallsyms.c b/kernel/kallsyms.c
>> index 60c20f301a6b..009b1ca21618 100644
>> --- a/kernel/kallsyms.c
>> +++ b/kernel/kallsyms.c
>> @@ -281,6 +281,8 @@ static unsigned long get_symbol_pos(unsigned long addr,
>>    			symbol_end = (unsigned long)_einittext;
>>    		else if (IS_ENABLED(CONFIG_KALLSYMS_ALL))
>>    			symbol_end = (unsigned long)_end;
>> +		else if (IS_ENABLED(CONFIG_HAVE_FUNCTION_DESCRIPTORS) && is_kernel_opd(addr))
>> +			symbol_end = (unsigned long)__end_opd;
> 
> Same, with the check included inside is_kernel_opd() you don't need the
> IS_ENABLED(CONFIG_HAVE_FUNCTION_DESCRIPTORS) here.
> 
>>    		else
>>    			symbol_end = (unsigned long)_etext;
>>    	}
>> diff --git a/scripts/kallsyms.c b/scripts/kallsyms.c
>> index 03fa07ad45d9..decf31c497f5 100644
>> --- a/scripts/kallsyms.c
>> +++ b/scripts/kallsyms.c
>> @@ -64,6 +64,7 @@ static unsigned long long relative_base;
>>    static struct addr_range text_ranges[] = {
>>    	{ "_stext",     "_etext"     },
>>    	{ "_sinittext", "_einittext" },
>> +	{ "__start_opd", "__end_opd" },
>>    };
>>    #define text_range_text     (&text_ranges[0])
>>    #define text_range_inittext (&text_ranges[1])
