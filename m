From: Max Filippov <jcmvbkbc@gmail.com>
Date: Thu, 04 Apr 2019 18:56:23 +0000
Subject: Re: [PATCH 5/6 v3] syscalls: Remove start and number from syscall_get_arguments() args
Message-Id: <CAMo8BfK8gdgni3z3PKv1rd0KPFMXgDCpicQQ_obuoDAEz3PkZQ@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20190401134104.676620247@goodmis.org> <20190401134421.278590567@goodmis.org>
In-Reply-To: <20190401134421.278590567@goodmis.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Steven Rostedt <rostedt@goodmis.org>
Cc: LKML <linux-kernel@vger.kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, Ingo Molnar <mingo@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Andy Lutomirski <luto@amacapital.net>, Roland McGrath <roland@hack.frob.com>, Oleg Nesterov <oleg@redhat.com>, Linux-Arch <linux-arch@vger.kernel.org>, Peter Zijlstra <peterz@infradead.org>, Thomas Gleixner <tglx@linutronix.de>, "Gustavo A. R. Silva" <gustavo@embeddedor.com>, Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, "H. Peter Anvin" <hpa@zytor.com>, "maintainer:X86 ARCHITECTURE..." <x86@kernel.org>, Dominik Brodowski <linux@dominikbrodowski.net>, Andy Lutomirski <luto@kernel.org>, Kees Cook <keescook@chromium.org>, "Eric W. Biederman" <ebiederm@xmission.com>, Dm

On Mon, Apr 1, 2019 at 6:45 AM Steven Rostedt <rostedt@goodmis.org> wrote:
>
> From: "Steven Rostedt (Red Hat)" <rostedt@goodmis.org>
>
> At Linux Plumbers, Andy Lutomirski approached me and pointed out that the
> function call syscall_get_arguments() implemented in x86 was horribly
> written and not optimized for the standard case of passing in 0 and 6 for
> the starting index and the number of system calls to get. When looking at
> all the users of this function, I discovered that all instances pass in only
> 0 and 6 for these arguments. Instead of having this function handle
> different cases that are never used, simply rewrite it to return the first 6
> arguments of a system call.
>
> This should help out the performance of tracing system calls by ptrace,
> ftrace and perf.

[...]

>  arch/xtensa/include/asm/syscall.h     | 16 ++----

For xtensa changes:
Acked-by: Max Filippov <jcmvbkbc@gmail.com>

-- 
Thanks.
-- Max
