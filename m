From: Dave Young <dyoung@redhat.com>
Date: Thu, 01 Dec 2016 04:56:53 +0000
Subject: Re: [PATCH v2 2/5] ia64: reuse append_elf_note() and final_note() functions
Message-Id: <20161201045653.GA13670@dhcp-128-65.nay.redhat.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <148007477669.1053.4107773905913128028.stgit@hbathini.in.ibm.com>
 <148007484315.1053.12317233313990302812.stgit@hbathini.in.ibm.com>
In-Reply-To: <148007484315.1053.12317233313990302812.stgit@hbathini.in.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Hari Bathini <hbathini@linux.vnet.ibm.com>
Cc: linux-kernel@vger.kernel.org, fenghua.yu@intel.com, tony.luck@intel.com, linux-ia64@vger.kernel.org, kexec@lists.infradead.org, linuxppc-dev@lists.ozlabs.org, ebiederm@xmission.com, Michael Ellerman <mpe@ellerman.id.au>, vgoyal@redhat.com

Hi Hari

Personally I like V1 more, but split the patch 2 is easier for ia64
people to reivew.  I did basic x86 testing, it runs ok.

On 11/25/16 at 05:24pm, Hari Bathini wrote:
> Get rid of multiple definitions of append_elf_note() & final_note()
> functions. Reuse these functions compiled under CONFIG_CRASH_CORE.
> 
> Signed-off-by: Hari Bathini <hbathini@linux.vnet.ibm.com>
> ---
>  arch/ia64/kernel/crash.c   |   22 ----------------------
>  include/linux/crash_core.h |    4 ++++
>  kernel/crash_core.c        |    6 +++---
>  kernel/kexec_core.c        |   28 ----------------------------
>  4 files changed, 7 insertions(+), 53 deletions(-)
> 
> diff --git a/arch/ia64/kernel/crash.c b/arch/ia64/kernel/crash.c
> index 2955f35..75859a0 100644
> --- a/arch/ia64/kernel/crash.c
> +++ b/arch/ia64/kernel/crash.c
> @@ -27,28 +27,6 @@ static int kdump_freeze_monarch;
>  static int kdump_on_init = 1;
>  static int kdump_on_fatal_mca = 1;
>  
> -static inline Elf64_Word
> -*append_elf_note(Elf64_Word *buf, char *name, unsigned type, void *data,
> -		size_t data_len)
> -{
> -	struct elf_note *note = (struct elf_note *)buf;
> -	note->n_namesz = strlen(name) + 1;
> -	note->n_descsz = data_len;
> -	note->n_type   = type;
> -	buf += (sizeof(*note) + 3)/4;
> -	memcpy(buf, name, note->n_namesz);
> -	buf += (note->n_namesz + 3)/4;
> -	memcpy(buf, data, data_len);
> -	buf += (data_len + 3)/4;
> -	return buf;
> -}
> -
> -static void
> -final_note(void *buf)
> -{
> -	memset(buf, 0, sizeof(struct elf_note));
> -}
> -

The above IA64 version looks better than the functions in kexec_core.c
about the Elf64_Word type usage and the simpler final_note function.

Care to update crash_core.c to use this instead?

Otherwise I'm fine with the changes.

>  extern void ia64_dump_cpu_regs(void *);
>  
>  static DEFINE_PER_CPU(struct elf_prstatus, elf_prstatus);
> diff --git a/include/linux/crash_core.h b/include/linux/crash_core.h
> index 9a4f4b0..2ae20b1 100644
> --- a/include/linux/crash_core.h
> +++ b/include/linux/crash_core.h
> @@ -61,6 +61,10 @@ extern u32 vmcoreinfo_note[VMCOREINFO_NOTE_SIZE/4];
>  extern size_t vmcoreinfo_size;
>  extern size_t vmcoreinfo_max_size;
>  
> +u32 *append_elf_note(u32 *buf, char *name, unsigned int type,
> +		     void *data, size_t data_len);
> +void final_note(u32 *buf);
> +
>  int __init parse_crashkernel(char *cmdline, unsigned long long system_ram,
>  		unsigned long long *crash_size, unsigned long long *crash_base);
>  int parse_crashkernel_high(char *cmdline, unsigned long long system_ram,
> diff --git a/kernel/crash_core.c b/kernel/crash_core.c
> index 60a98fc..9223976 100644
> --- a/kernel/crash_core.c
> +++ b/kernel/crash_core.c
> @@ -291,8 +291,8 @@ int __init parse_crashkernel_low(char *cmdline,
>  				"crashkernel=", suffix_tbl[SUFFIX_LOW]);
>  }
>  
> -static u32 *append_elf_note(u32 *buf, char *name, unsigned int type,
> -			    void *data, size_t data_len)
> +u32 *append_elf_note(u32 *buf, char *name, unsigned int type,
> +		     void *data, size_t data_len)
>  {
>  	struct elf_note note;
>  
> @@ -309,7 +309,7 @@ static u32 *append_elf_note(u32 *buf, char *name, unsigned int type,
>  	return buf;
>  }
>  
> -static void final_note(u32 *buf)
> +void final_note(u32 *buf)
>  {
>  	struct elf_note note;
>  
> diff --git a/kernel/kexec_core.c b/kernel/kexec_core.c
> index 3aa21f3..596cb32 100644
> --- a/kernel/kexec_core.c
> +++ b/kernel/kexec_core.c
> @@ -988,34 +988,6 @@ int crash_shrink_memory(unsigned long new_size)
>  	return ret;
>  }
>  
> -static u32 *append_elf_note(u32 *buf, char *name, unsigned type, void *data,
> -			    size_t data_len)
> -{
> -	struct elf_note note;
> -
> -	note.n_namesz = strlen(name) + 1;
> -	note.n_descsz = data_len;
> -	note.n_type   = type;
> -	memcpy(buf, &note, sizeof(note));
> -	buf += (sizeof(note) + 3)/4;
> -	memcpy(buf, name, note.n_namesz);
> -	buf += (note.n_namesz + 3)/4;
> -	memcpy(buf, data, note.n_descsz);
> -	buf += (note.n_descsz + 3)/4;
> -
> -	return buf;
> -}
> -
> -static void final_note(u32 *buf)
> -{
> -	struct elf_note note;
> -
> -	note.n_namesz = 0;
> -	note.n_descsz = 0;
> -	note.n_type   = 0;
> -	memcpy(buf, &note, sizeof(note));
> -}
> -
>  void crash_save_cpu(struct pt_regs *regs, int cpu)
>  {
>  	struct elf_prstatus prstatus;
> 
> 
> _______________________________________________
> kexec mailing list
> kexec@lists.infradead.org
> http://lists.infradead.org/mailman/listinfo/kexec

Thanks
Dave
