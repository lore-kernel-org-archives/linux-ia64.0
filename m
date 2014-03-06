From: Kees Cook <keescook@chromium.org>
Date: Thu, 06 Mar 2014 21:25:27 +0000
Subject: Re: [patch 10/20] kallsyms: fix absolute addresses for kASLR
Message-Id: <CAGXu5jKHa1-N5WGxpYq8k_w8rGaMwWUwCC7L1kCq=iZkaNuKFA@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <87k3c8yr9u.fsf@rustcorp.com.au>
In-Reply-To: <87k3c8yr9u.fsf@rustcorp.com.au>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, Mar 5, 2014 at 6:50 PM, Rusty Russell <rusty@rustcorp.com.au> wrote:
> Kees Cook <keescook@chromium.org> writes:
>> [+x86 folks]
>>
>> On Tue, Mar 4, 2014 at 7:57 AM, Linus Torvalds
>> <torvalds@linux-foundation.org> wrote:
>>> On Mon, Mar 3, 2014 at 3:55 PM, Kees Cook <keescook@chromium.org> wrote:
>>>> This got NAKed, please don't apply -- this patch works for x86 and
>>>> ARM, but may cause problems for others:
>>>
>>> I'd much rather fix x86 and ARM, than worry about avr32.
>>>
>>> Priorities, people.
>>>
>>> Somebody who knows how "fix this properly" is supposed to work?
>>
>> I have not yet had a chance to more carefully examine the options, but
>> AIUI, the problem is that (at least) the "per cpu" variables are
>> neither absolute nor relative addresses from a relocation perspective.
>> They're relative to the per cpu area, but the linker tools don't know
>> about that state. So, I think, to fix this correctly, we need to teach
>> the linker tools about this third state. This may also help
>> arch/x86/tools/relocs, which is currently using a whitelist for
>> mis-identified variables.
>
> Well, __per_cpu_start points into a real section, within the discarded
> init region.  Makes me wonder why it's zero in /proc/kallsyms (it is on
> my Ubuntu system here too).
>
> ... digging ...
>
> Ah, the zero-based percpu patches, of course.  Gah.
>
> How's this?  Did I break IA64?
>
> => kallsyms: make zero-based __per_cpu_start & __per_cpu_end absolute symbols.
>
> Andy reported that x86-64 with CONFIG_RANDOMIZE_BASE has bogus values
> for __per_cpu_start and __per_cpu_end in /proc/kallsyms:

Well, just to make sure it's clear: __per_cpu_start/_end are just
markers, and everything between them is mishandled as well, not just
things named "__per_cpu" ...

>
>     Several kallsyms output in different boot states for comparison:
>
>     $ egrep '_(stext|_per_cpu_(start|end))' /root/kallsyms.nokaslr
>     0000000000000000 D __per_cpu_start
>     0000000000014280 D __per_cpu_end
>     ffffffff810001c8 T _stext
>     $ egrep '_(stext|_per_cpu_(start|end))' /root/kallsyms.kaslr1
>     000000001f200000 D __per_cpu_start
>     000000001f214280 D __per_cpu_end
>     ffffffffa02001c8 T _stext
>     $ egrep '_(stext|_per_cpu_(start|end))' /root/kallsyms.kaslr2
>     000000000d400000 D __per_cpu_start
>     000000000d414280 D __per_cpu_end
>     ffffffff8e4001c8 T _stext
>     $ egrep '_(stext|_per_cpu_(start|end))' /root/kallsyms.kaslr-fixed
>     0000000000000000 D __per_cpu_start
>     0000000000014280 D __per_cpu_end
>     ffffffffadc001c8 T _stext
>
> x86-64 pretends that the per_cpu section is at address 0, and thus the
> __per_cpu_start and __per_cpu_end resolve to 0 and <smallnum>.
>
> kallsyms encodes the addresses in the kallsyms_addresses[] as relative
> to _text: this means they get automatically relocated when the kernel
> gets moved.  But that's clearly wrong for the case where these are
> fixed addresses.
>
> /proc/kallsyms already handles absolute symbols, so just make
> __per_cpu_start and __per_cpu_end absolute, and add them to the
> inclusive list so kallsyms doesn't filter them out.
>
> We make the change to absolute symbols in the PERCPU_VADDR linker
> script macro, which is only used by x86 (when !CONFIG_X86_32) and
> ia64, to place the per-cpu section at a specific address.  This means
> that using PERCPU_VADDR is wrong if you don't want an absolute
> address, so we remove the comment about the vaddr arg being optional.
>
> The comment on PERCPU_VADDR says __per_cpu_load is an absolute symbol,
> but it isn't (and I don't think it should be).  Delete that.
>
> Reported-by: Andy Honig <ahonig@google.com>
> Signed-off-by: Rusty Russell <rusty@rustcorp.com.au>
>
> diff --git a/include/asm-generic/vmlinux.lds.h b/include/asm-generic/vmlinux.lds.h
> index bc2121fa9132..c70e6242d1d6 100644
> --- a/include/asm-generic/vmlinux.lds.h
> +++ b/include/asm-generic/vmlinux.lds.h
> @@ -674,6 +674,16 @@
>         *(.discard.*)                                                   \
>         }
>
> +#define __PERCPU_INPUT(cacheline)                                      \
> +       *(.data..percpu..first)                                         \
> +       . = ALIGN(PAGE_SIZE);                                           \
> +       *(.data..percpu..page_aligned)                                  \
> +       . = ALIGN(cacheline);                                           \
> +       *(.data..percpu..readmostly)                                    \
> +       . = ALIGN(cacheline);                                           \
> +       *(.data..percpu)                                                \
> +       *(.data..percpu..shared_aligned)                                \
> +
>  /**
>   * PERCPU_INPUT - the percpu input sections
>   * @cacheline: cacheline size
> @@ -686,20 +697,13 @@
>   */
>  #define PERCPU_INPUT(cacheline)                                                \
>         VMLINUX_SYMBOL(__per_cpu_start) = .;                            \
> -       *(.data..percpu..first)                                         \
> -       . = ALIGN(PAGE_SIZE);                                           \
> -       *(.data..percpu..page_aligned)                                  \
> -       . = ALIGN(cacheline);                                           \
> -       *(.data..percpu..readmostly)                                    \
> -       . = ALIGN(cacheline);                                           \
> -       *(.data..percpu)                                                \
> -       *(.data..percpu..shared_aligned)                                \
> +       __PERCPU_INPUT(cacheline)                                       \
>         VMLINUX_SYMBOL(__per_cpu_end) = .;
>
>  /**
>   * PERCPU_VADDR - define output section for percpu area
>   * @cacheline: cacheline size
> - * @vaddr: explicit base address (optional)
> + * @vaddr: explicit base address
>   * @phdr: destination PHDR (optional)
>   *
>   * Macro which expands to output section for percpu area.
> @@ -707,24 +711,25 @@
>   * @cacheline is used to align subsections to avoid false cacheline
>   * sharing between subsections for different purposes.
>   *
> - * If @vaddr is not blank, it specifies explicit base address and all
> - * percpu symbols will be offset from the given address.  If blank,
> - * @vaddr always equals @laddr + LOAD_OFFSET.
> + * @vaddr specifies explicit base address and all
> + * percpu symbols will be offset from the given address.
>   *
>   * @phdr defines the output PHDR to use if not blank.  Be warned that
>   * output PHDR is sticky.  If @phdr is specified, the next output
>   * section in the linker script will go there too.  @phdr should have
>   * a leading colon.
>   *
> - * Note that this macros defines __per_cpu_load as an absolute symbol.
> - * If there is no need to put the percpu section at a predetermined
> - * address, use PERCPU_SECTION.
> + * Note that this macros define __per_cpu_start and __per_cpu_end as
> + * absolute addresses.  If there is no need to put the percpu section
> + * at a predetermined address, use PERCPU_SECTION.
>   */
>  #define PERCPU_VADDR(cacheline, vaddr, phdr)                           \
>         VMLINUX_SYMBOL(__per_cpu_load) = .;                             \
>         .data..percpu vaddr : AT(VMLINUX_SYMBOL(__per_cpu_load)         \
>                                 - LOAD_OFFSET) {                        \
> -               PERCPU_INPUT(cacheline)                                 \
> +               VMLINUX_SYMBOL(__per_cpu_start) = ABSOLUTE(.);          \
> +               __PERCPU_INPUT(cacheline)                               \
> +               VMLINUX_SYMBOL(__per_cpu_end) = ABSOLUTE(.);            \

I think this portion interacts badly with the x86 relocs tool which is
trying to find the per_cpu area via percpu_init(), which looks for the
section name ".data..percpu".

>         } phdr                                                          \
>         . = VMLINUX_SYMBOL(__per_cpu_load) + SIZEOF(.data..percpu);
>
> diff --git a/scripts/kallsyms.c b/scripts/kallsyms.c
> index 10085de886fe..d6782918fe17 100644
> --- a/scripts/kallsyms.c
> +++ b/scripts/kallsyms.c
> @@ -138,6 +138,7 @@ static int read_symbol(FILE *in, struct sym_entry *s)
>                 if (strcmp(sym, "__kernel_syscall_via_break") &&
>                     strcmp(sym, "__kernel_syscall_via_epc") &&
>                     strcmp(sym, "__kernel_sigtramp") &&
> +                   strncmp(sym, "__per_cpu", strlen("__per_cpu")) &&
>                     strcmp(sym, "__gp"))
>                         return -1;

We need to keep everything between _start and _end, and they don't
have the __per_cpu prefix:

0000000000000000 D irq_stack_union
0000000000000000 D __per_cpu_start
0000000000004000 D gdt_page
0000000000005000 d exception_stacks
000000000000b000 D cpu_llc_shared_map
000000000000b008 D cpu_core_map
000000000000b010 D cpu_sibling_map
000000000000b018 D cpu_llc_id
...
0000000000013fc0 d call_single_queue
0000000000014000 d cfd_data
0000000000014040 d csd_data
0000000000014080 D softnet_data
0000000000014280 D __per_cpu_end

-Kees

-- 
Kees Cook
Chrome OS Security
