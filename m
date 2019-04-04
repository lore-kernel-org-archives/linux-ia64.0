From: Thomas Gleixner <tglx@linutronix.de>
Date: Thu, 04 Apr 2019 07:52:56 +0000
Subject: Re: [PATCH 5/6 v3] syscalls: Remove start and number from syscall_get_arguments() args
Message-Id: <alpine.DEB.2.21.1904040952280.1833@nanos.tec.linutronix.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20190401134104.676620247@goodmis.org>
 <20190401134421.278590567@goodmis.org>
In-Reply-To: <20190401134421.278590567@goodmis.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Steven Rostedt <rostedt@goodmis.org>
Cc: linux-ia64@vger.kernel.org, "Gustavo A. R. Silva" <gustavo@embeddedor.com>, Peter Zijlstra <peterz@infradead.org>, Palmer Dabbelt <palmer@sifive.com>, Dominik Brodowski <linux@dominikbrodowski.net>, Oleg Nesterov <oleg@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, sparclinux@vger.kernel.org, linux-riscv@lists.infradead.org, Ingo Molnar <mingo@kernel.org>, linux-arch@vger.kernel.org, linux-s390@vger.kernel.org, linux-c6x-dev@linux-c6x.org, linux-sh@vger.kernel.org, linux-hexagon@vger.kernel.org, x86@kernel.org, Ingo Molnar <mingo@redhat.com>, linux-snps-arc@lists.infradead.org, Dave Martin <dave.martin@arm.com>, uclinux-h8-devel@lists.sourceforge.jp, linux-xtensa@linux-xtensa.org, Kees Cook <keescook@chromium.org>, Roland McGrath <roland@hack.frob.com>, linux-um@lists.infradead.org, linux-mips@vger.kernel.org, openrisc@lists.librecores.org, Borislav Petkov <bp@alien8.de>

On Mon, 1 Apr 2019, Steven Rostedt wrote:

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
> 
> Link: http://lkml.kernel.org/r/20161107213233.754809394@goodmis.org

For x86:

Reviewed-by: Thomas Gleixner <tglx@linutronix.de>
