From: n0ano@indstorage.com
Date: Thu, 18 Apr 2002 14:13:54 +0000
Subject: Re: [Linux-ia64] Clean up IA32 support a little...
Message-Id: <marc-linux-ia64-105590701905483@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701905482@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701905482@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Peter-

This seems reasonable to me.

About module support, I haven't really given that a thought although
it might be a good idea.  Especially as the need for IA32 support
drops off it would make sense to provide this as a module, just in
case.  I'll add this to the ToDo list.

On Thu, Apr 18, 2002 at 11:17:06AM +1000, Peter Chubb wrote:
> 
> Hi,
> 	The attached patch cleans up IA32 support a little.
> As it's impossible at present to compile and use IA32 support as a
> module, disallow that; and also provide dummy functions to remove
> compilation warnings if CONFIG_IA32_SUPPORT is off.
> 
> 
> # This is a BitKeeper generated patch for the following project:
> # Project Name: Linux kernel tree
> # This patch format is intended for GNU patch command version 2.5 or higher.
> # This patch includes the following deltas:
> #	           ChangeSet	1.494   -> 1.495  
> #	include/asm-ia64/system.h	1.9     -> 1.10   
> #	 arch/ia64/config.in	1.16    -> 1.17   
> #
> # The following is the BitKeeper ChangeSet Log
> # --------------------------------------------
> # 02/04/18	peterc@redback.cse.unsw.edu.au	1.495
> # Disallow compiling IA32 support as a module (it doesn't work) and make sure that 
> # if IA32 support is not enabled, the resulting compilation com,pletes without warnings.
> # --------------------------------------------
> #
> diff -Nru a/arch/ia64/config.in b/arch/ia64/config.in
> --- a/arch/ia64/config.in	Thu Apr 18 11:14:25 2002
> +++ b/arch/ia64/config.in	Thu Apr 18 11:14:25 2002
> @@ -83,7 +83,7 @@
>  define_bool CONFIG_KCORE_ELF y	# On IA-64, we always want an ELF /proc/kcore.
>  
>  bool 'SMP support' CONFIG_SMP
> -tristate 'Support running of Linux/x86 binaries' CONFIG_IA32_SUPPORT
> +bool 'Support running of Linux/x86 binaries' CONFIG_IA32_SUPPORT
>  bool 'Performance monitor support' CONFIG_PERFMON
>  tristate '/proc/pal support' CONFIG_IA64_PALINFO
>  tristate '/proc/efi/vars support' CONFIG_EFI_VARS
> diff -Nru a/include/asm-ia64/system.h b/include/asm-ia64/system.h
> --- a/include/asm-ia64/system.h	Thu Apr 18 11:14:25 2002
> +++ b/include/asm-ia64/system.h	Thu Apr 18 11:14:25 2002
> @@ -353,6 +353,9 @@
>  # define IS_IA32_PROCESS(regs)	(ia64_psr(regs)->is != 0)
>  #else
>  # define IS_IA32_PROCESS(regs)		0
> +struct task_struct;
> +static inline void ia32_save_state(struct task_struct *t __attribute__((unused))){}
> +static inline void ia32_load_state(struct task_struct *t __attribute__((unused))){}
>  #endif
>  
>  /*
> 
> _______________________________________________
> Linux-IA64 mailing list
> Linux-IA64@linuxia64.org
> http://lists.linuxia64.org/lists/listinfo/linux-ia64

-- 
Don Dugger
"Censeo Toto nos in Kansa esse decisse." - D. Gale
n0ano@indstorage.com
Ph: 303/652-0870x117

