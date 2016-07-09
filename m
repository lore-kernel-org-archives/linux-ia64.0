From: Kees Cook <keescook@chromium.org>
Date: Sat, 09 Jul 2016 17:01:18 +0000
Subject: Re: [PATCH 0/9] mm: Hardened usercopy
Message-Id: <CAGXu5jJVQCMZQm-zT07Siniiic9DSK7ZC=qdDMgFLwBpfEqYSg@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1467843928-29351-1-git-send-email-keescook@chromium.org> <b113b487-acc6-24b8-d58c-425d3c884f4c@redhat.com>
In-Reply-To: <b113b487-acc6-24b8-d58c-425d3c884f4c@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Laura Abbott <labbott@redhat.com>
Cc: LKML <linux-kernel@vger.kernel.org>, Rik van Riel <riel@redhat.com>, Casey Schaufler <casey@schaufler-ca.com>, PaX Team <pageexec@freemail.hu>, Brad Spengler <spender@grsecurity.net>, Russell King <linux@armlinux.org.uk>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Michael Ellerman <mpe@ellerman.id.au>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, "David S. Miller" <davem@davemloft.net>, "x86@kernel.org" <x86@kernel.org>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, Borislav Petkov <bp@suse.de>, Mathias Krause <minipli@googlemail.com>, Jan Kara <jack@suse.cz>, Vitaly Wool <vitalywool@gmail.com>, Andrea Arcangeli <aarcange@redhat.com>, Dmitry Vyukov <dvyukov@google.com>, Laura Abbott <labbott@fedoraproject.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, linux-ia64@vger.kernel.org, "linuxppc-dev@lists.ozlabs.org" <linuxppc-dev@lists.ozlabs.org>, sparclinux <sparclinux@vger.kernel.org>, linux-arch <linux-arch@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, "kernel-hardening@lists.openwall.com" <kernel-hardening@lists.openwall.com>

On Fri, Jul 8, 2016 at 7:22 PM, Laura Abbott <labbott@redhat.com> wrote:
> On 07/06/2016 03:25 PM, Kees Cook wrote:
>>
>> Hi,
>>
>> This is a start of the mainline port of PAX_USERCOPY[1]. After I started
>> writing tests (now in lkdtm in -next) for Casey's earlier port[2], I
>> kept tweaking things further and further until I ended up with a whole
>> new patch series. To that end, I took Rik's feedback and made a number
>> of other changes and clean-ups as well.
>>
>> Based on my understanding, PAX_USERCOPY was designed to catch a few
>> classes of flaws around the use of copy_to_user()/copy_from_user(). These
>> changes don't touch get_user() and put_user(), since these operate on
>> constant sized lengths, and tend to be much less vulnerable. There
>> are effectively three distinct protections in the whole series,
>> each of which I've given a separate CONFIG, though this patch set is
>> only the first of the three intended protections. (Generally speaking,
>> PAX_USERCOPY covers what I'm calling CONFIG_HARDENED_USERCOPY (this) and
>> CONFIG_HARDENED_USERCOPY_WHITELIST (future), and PAX_USERCOPY_SLABS covers
>> CONFIG_HARDENED_USERCOPY_SPLIT_KMALLOC (future).)
>>
>> This series, which adds CONFIG_HARDENED_USERCOPY, checks that objects
>> being copied to/from userspace meet certain criteria:
>> - if address is a heap object, the size must not exceed the object's
>>   allocated size. (This will catch all kinds of heap overflow flaws.)
>> - if address range is in the current process stack, it must be within the
>>   current stack frame (if such checking is possible) or at least entirely
>>   within the current process's stack. (This could catch large lengths that
>>   would have extended beyond the current process stack, or overflows if
>>   their length extends back into the original stack.)
>> - if the address range is part of kernel data, rodata, or bss, allow it.
>> - if address range is page-allocated, that it doesn't span multiple
>>   allocations.
>> - if address is within the kernel text, reject it.
>> - everything else is accepted
>>
>> The patches in the series are:
>> - The core copy_to/from_user() checks, without the slab object checks:
>>         1- mm: Hardened usercopy
>> - Per-arch enablement of the protection:
>>         2- x86/uaccess: Enable hardened usercopy
>>         3- ARM: uaccess: Enable hardened usercopy
>>         4- arm64/uaccess: Enable hardened usercopy
>>         5- ia64/uaccess: Enable hardened usercopy
>>         6- powerpc/uaccess: Enable hardened usercopy
>>         7- sparc/uaccess: Enable hardened usercopy
>> - The heap allocator implementation of object size checking:
>>         8- mm: SLAB hardened usercopy support
>>         9- mm: SLUB hardened usercopy support
>>
>> Some notes:
>>
>> - This is expected to apply on top of -next which contains fixes for the
>>   position of _etext on both arm and arm64.
>>
>> - I couldn't detect a measurable performance change with these features
>>   enabled. Kernel build times were unchanged, hackbench was unchanged,
>>   etc. I think we could flip this to "on by default" at some point.
>>
>> - The SLOB support extracted from grsecurity seems entirely broken. I
>>   have no idea what's going on there, I spent my time testing SLAB and
>>   SLUB. Having someone else look at SLOB would be nice, but this series
>>   doesn't depend on it.
>>
>> Additional features that would be nice, but aren't blocking this series:
>>
>> - Needs more architecture support for stack frame checking (only x86 now).
>>
>>
>
> Even with the SLUB fixup I'm still seeing this blow up on my arm64 system.
> This is a
> Fedora rawhide kernel + the patches

Is this on top of -next? The recent _etext change ("arm64: mm: fix
location of _etext") is needed to fix the kernel text test for arm64.

-Kees

>
> [    0.666700] usercopy: kernel memory exposure attempt detected from
> fffffc0008b4dd58 (<kernel text>) (8 bytes)
> [    0.666720] CPU: 2 PID: 79 Comm: modprobe Tainted: G        W
> 4.7.0-0.rc6.git1.1.hardenedusercopy.fc25.aarch64 #1
> [    0.666733] Hardware name: AppliedMicro Mustang/Mustang, BIOS 1.1.0 Nov
> 24 2015
> [    0.666744] Call trace:
> [    0.666756] [<fffffc0008088a20>] dump_backtrace+0x0/0x1e8
> [    0.666765] [<fffffc0008088c2c>] show_stack+0x24/0x30
> [    0.666775] [<fffffc0008455344>] dump_stack+0xa4/0xe0
> [    0.666785] [<fffffc000828d874>] __check_object_size+0x6c/0x230
> [    0.666795] [<fffffc00083a5748>] create_elf_tables+0x74/0x420
> [    0.666805] [<fffffc00082fb1f0>] load_elf_binary+0x828/0xb70
> [    0.666814] [<fffffc0008298b4c>] search_binary_handler+0xb4/0x240
> [    0.666823] [<fffffc0008299864>] do_execveat_common+0x63c/0x950
> [    0.666832] [<fffffc0008299bb4>] do_execve+0x3c/0x50
> [    0.666841] [<fffffc00080e3720>]
> call_usermodehelper_exec_async+0xe8/0x148
> [    0.666850] [<fffffc0008084a80>] ret_from_fork+0x10/0x50
>
> This happens on every call to execve. This seems to be the first
> copy_to_user in
> create_elf_tables. I didn't get a chance to debug and I'm going out of town
> all of next week so all I have is the report unfortunately. config attached.
>
> Thanks,
> Laura



-- 
Kees Cook
Chrome OS & Brillo Security
