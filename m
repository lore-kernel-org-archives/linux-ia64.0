From: Paul Moore <paul@paul-moore.com>
Date: Thu, 21 Mar 2019 01:22:35 +0000
Subject: Re: [PATCH v2 13/13] syscall_get_arch: add "struct task_struct *" argument
Message-Id: <CAHC9VhQWKT8Mr=_pcmiccpChMB9oufUHO-4Agzmot7M=6ShNnw@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20190317233018.GN16301@altlinux.org>
In-Reply-To: <20190317233018.GN16301@altlinux.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Dmitry V. Levin" <ldv@altlinux.org>
Cc: Andy Lutomirski <luto@kernel.org>, Palmer Dabbelt <palmer@sifive.com>, Paul Burton <paul.burton@mips.com>, Michael Ellerman <mpe@ellerman.id.au>, Kees Cook <keescook@chromium.org>, Mark Salter <msalter@redhat.com>, Elvira Khabirova <lineprinter@altlinux.org>, Eugene Syromyatnikov <esyr@redhat.com>, Oleg Nesterov <oleg@redhat.com>, x86@kernel.org, linux-alpha@vger.kernel.org, linux-snps-arc@lists.infradead.org, linux-arm-kernel@lists.infradead.org, linux-c6x-dev@linux-c6x.org, uclinux-h8-devel@lists.sourceforge.jp, linux-hexagon@vger.kernel.org, linux-ia64@vger.kernel.org, linux-m68k@lists.linux-m68k.org, linux-mips@vger.kernel.org, nios2-dev@lists.rocketboards.org, openrisc@lists.librecores.org, linux-parisc@vger.kernel.org, linuxppc-dev@lists.ozlabs.orgli

On Sun, Mar 17, 2019 at 7:30 PM Dmitry V. Levin <ldv@altlinux.org> wrote:
>
> This argument is required to extend the generic ptrace API with
> PTRACE_GET_SYSCALL_INFO request: syscall_get_arch() is going
> to be called from ptrace_request() along with syscall_get_nr(),
> syscall_get_arguments(), syscall_get_error(), and
> syscall_get_return_value() functions with a tracee as their argument.
>
> The primary intent is that the triple (audit_arch, syscall_nr, arg1..arg6)
> should describe what system call is being called and what its arguments
> are.
>
> Reverts: 5e937a9ae913 ("syscall_get_arch: remove useless function arguments")
> Reverts: 1002d94d3076 ("syscall.h: fix doc text for syscall_get_arch()")
> Reviewed-by: Andy Lutomirski <luto@kernel.org> # for x86
> Reviewed-by: Palmer Dabbelt <palmer@sifive.com>
> Acked-by: Paul Moore <paul@paul-moore.com>
> Acked-by: Paul Burton <paul.burton@mips.com> # MIPS parts
> Acked-by: Michael Ellerman <mpe@ellerman.id.au> (powerpc)
> Acked-by: Kees Cook <keescook@chromium.org> # seccomp parts
> Acked-by: Mark Salter <msalter@redhat.com> # for the c6x bit
> Cc: Elvira Khabirova <lineprinter@altlinux.org>
> Cc: Eugene Syromyatnikov <esyr@redhat.com>
> Cc: Oleg Nesterov <oleg@redhat.com>
> Cc: x86@kernel.org
> Cc: linux-alpha@vger.kernel.org
> Cc: linux-snps-arc@lists.infradead.org
> Cc: linux-arm-kernel@lists.infradead.org
> Cc: linux-c6x-dev@linux-c6x.org
> Cc: uclinux-h8-devel@lists.sourceforge.jp
> Cc: linux-hexagon@vger.kernel.org
> Cc: linux-ia64@vger.kernel.org
> Cc: linux-m68k@lists.linux-m68k.org
> Cc: linux-mips@vger.kernel.org
> Cc: nios2-dev@lists.rocketboards.org
> Cc: openrisc@lists.librecores.org
> Cc: linux-parisc@vger.kernel.org
> Cc: linuxppc-dev@lists.ozlabs.org
> Cc: linux-riscv@lists.infradead.org
> Cc: linux-s390@vger.kernel.org
> Cc: linux-sh@vger.kernel.org
> Cc: sparclinux@vger.kernel.org
> Cc: linux-um@lists.infradead.org
> Cc: linux-xtensa@linux-xtensa.org
> Cc: linux-arch@vger.kernel.org
> Cc: linux-audit@redhat.com
> Signed-off-by: Dmitry V. Levin <ldv@altlinux.org>
> ---
>
> Notes:
>     v2: unchanged
>
>  arch/alpha/include/asm/syscall.h      |  2 +-
>  arch/arc/include/asm/syscall.h        |  2 +-
>  arch/arm/include/asm/syscall.h        |  2 +-
>  arch/arm64/include/asm/syscall.h      |  4 ++--
>  arch/c6x/include/asm/syscall.h        |  2 +-
>  arch/csky/include/asm/syscall.h       |  2 +-
>  arch/h8300/include/asm/syscall.h      |  2 +-
>  arch/hexagon/include/asm/syscall.h    |  2 +-
>  arch/ia64/include/asm/syscall.h       |  2 +-
>  arch/m68k/include/asm/syscall.h       |  2 +-
>  arch/microblaze/include/asm/syscall.h |  2 +-
>  arch/mips/include/asm/syscall.h       |  6 +++---
>  arch/mips/kernel/ptrace.c             |  2 +-
>  arch/nds32/include/asm/syscall.h      |  2 +-
>  arch/nios2/include/asm/syscall.h      |  2 +-
>  arch/openrisc/include/asm/syscall.h   |  2 +-
>  arch/parisc/include/asm/syscall.h     |  4 ++--
>  arch/powerpc/include/asm/syscall.h    | 10 ++++++++--
>  arch/riscv/include/asm/syscall.h      |  2 +-
>  arch/s390/include/asm/syscall.h       |  4 ++--
>  arch/sh/include/asm/syscall_32.h      |  2 +-
>  arch/sh/include/asm/syscall_64.h      |  2 +-
>  arch/sparc/include/asm/syscall.h      |  5 +++--
>  arch/unicore32/include/asm/syscall.h  |  2 +-
>  arch/x86/include/asm/syscall.h        |  8 +++++---
>  arch/x86/um/asm/syscall.h             |  2 +-
>  arch/xtensa/include/asm/syscall.h     |  2 +-
>  include/asm-generic/syscall.h         |  5 +++--
>  kernel/auditsc.c                      |  4 ++--
>  kernel/seccomp.c                      |  4 ++--
>  30 files changed, 52 insertions(+), 42 deletions(-)

Merged into audit/next, thanks everyone.

-- 
paul moore
www.paul-moore.com
