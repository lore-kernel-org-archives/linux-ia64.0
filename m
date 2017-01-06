From: Dave Young <dyoung@redhat.com>
Date: Fri, 06 Jan 2017 02:03:24 +0000
Subject: Re: [PATCH v4 2/5] ia64: reuse append_elf_note() and final_note() functions
Message-Id: <20170106020324.GB2863@dhcp-128-65.nay.redhat.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <148363729327.11570.6244765717789390817.stgit@hbathini.in.ibm.com>
 <148363740554.11570.4870634597647436827.stgit@hbathini.in.ibm.com>
In-Reply-To: <148363740554.11570.4870634597647436827.stgit@hbathini.in.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Hari Bathini <hbathini@linux.vnet.ibm.com>
Cc: linux-kernel@vger.kernel.org, fenghua.yu@intel.com, tony.luck@intel.com, linux-ia64@vger.kernel.org, kexec@lists.infradead.org, Mahesh J Salgaonkar <mahesh@linux.vnet.ibm.com>, ebiederm@xmission.com, Michael Ellerman <mpe@ellerman.id.au>, linuxppc-dev@lists.ozlabs.org, vgoyal@redhat.com

On 01/05/17 at 11:01pm, Hari Bathini wrote:
> Get rid of multiple definitions of append_elf_note() & final_note()
> functions. Reuse these functions compiled under CONFIG_CRASH_CORE
> Also, define Elf_Word and use it instead of generic u32 or the more
> specific Elf64_Word.
> 
> Signed-off-by: Hari Bathini <hbathini@linux.vnet.ibm.com>
> ---
> 
> Changes from v3:
> * Dropped hard-coded values and used DIV_ROUND_UP().
> 
> Changes from v2:
> * Added a definition for Elf_Word.
> * Used IA64 version of append_elf_note() and final_note() functions.
> 
> 
>  arch/ia64/kernel/crash.c   |   22 ----------------------
>  include/linux/crash_core.h |    4 ++++
>  include/linux/elf.h        |    2 ++
>  kernel/crash_core.c        |   34 ++++++++++++++--------------------
>  kernel/kexec_core.c        |   28 ----------------------------
>  5 files changed, 20 insertions(+), 70 deletions(-)
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
>  extern void ia64_dump_cpu_regs(void *);
>  
>  static DEFINE_PER_CPU(struct elf_prstatus, elf_prstatus);
> diff --git a/include/linux/crash_core.h b/include/linux/crash_core.h
> index 18d0f94..541a197 100644
> --- a/include/linux/crash_core.h
> +++ b/include/linux/crash_core.h
> @@ -55,6 +55,10 @@ extern u32 vmcoreinfo_note[VMCOREINFO_NOTE_SIZE/4];
>  extern size_t vmcoreinfo_size;
>  extern size_t vmcoreinfo_max_size;
>  
> +Elf_Word *append_elf_note(Elf_Word *buf, char *name, unsigned int type,
> +			  void *data, size_t data_len);
> +void final_note(Elf_Word *buf);
> +
>  int __init parse_crashkernel(char *cmdline, unsigned long long system_ram,
>  		unsigned long long *crash_size, unsigned long long *crash_base);
>  int parse_crashkernel_high(char *cmdline, unsigned long long system_ram,
> diff --git a/include/linux/elf.h b/include/linux/elf.h
> index 20fa8d8..ba069e8 100644
> --- a/include/linux/elf.h
> +++ b/include/linux/elf.h
> @@ -29,6 +29,7 @@ extern Elf32_Dyn _DYNAMIC [];
>  #define elf_note	elf32_note
>  #define elf_addr_t	Elf32_Off
>  #define Elf_Half	Elf32_Half
> +#define Elf_Word	Elf32_Word
>  
>  #else
>  
> @@ -39,6 +40,7 @@ extern Elf64_Dyn _DYNAMIC [];
>  #define elf_note	elf64_note
>  #define elf_addr_t	Elf64_Off
>  #define Elf_Half	Elf64_Half
> +#define Elf_Word	Elf64_Word
>  
>  #endif
>  
> diff --git a/kernel/crash_core.c b/kernel/crash_core.c
> index 80b441d..362dace 100644
> --- a/kernel/crash_core.c
> +++ b/kernel/crash_core.c
> @@ -291,32 +291,26 @@ int __init parse_crashkernel_low(char *cmdline,
>  				"crashkernel=", suffix_tbl[SUFFIX_LOW]);
>  }
>  
> -static u32 *append_elf_note(u32 *buf, char *name, unsigned int type,
> -			    void *data, size_t data_len)
> +Elf_Word *append_elf_note(Elf_Word *buf, char *name, unsigned int type,
> +			  void *data, size_t data_len)
>  {
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
> +	struct elf_note *note = (struct elf_note *)buf;
> +
> +	note->n_namesz = strlen(name) + 1;
> +	note->n_descsz = data_len;
> +	note->n_type   = type;
> +	buf += DIV_ROUND_UP(sizeof(*note), sizeof(Elf_Word));
> +	memcpy(buf, name, note->n_namesz);
> +	buf += DIV_ROUND_UP(note->n_namesz, sizeof(Elf_Word));
> +	memcpy(buf, data, data_len);
> +	buf += DIV_ROUND_UP(data_len, sizeof(Elf_Word));
>  
>  	return buf;
>  }
>  
> -static void final_note(u32 *buf)
> +void final_note(Elf_Word *buf)
>  {
> -	struct elf_note note;
> -
> -	note.n_namesz = 0;
> -	note.n_descsz = 0;
> -	note.n_type   = 0;
> -	memcpy(buf, &note, sizeof(note));
> +	memset(buf, 0, sizeof(struct elf_note));
>  }
>  
>  static void update_vmcoreinfo_note(void)
> diff --git a/kernel/kexec_core.c b/kernel/kexec_core.c
> index 2179a16..263d764 100644
> --- a/kernel/kexec_core.c
> +++ b/kernel/kexec_core.c
> @@ -990,34 +990,6 @@ int crash_shrink_memory(unsigned long new_size)
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

It looks good to me. But better to have words from IA64 people as well.

Acked-by: Dave Young <dyoung@redhat.com>

Thanks
Dave
