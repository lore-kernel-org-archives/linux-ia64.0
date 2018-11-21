From: Andy Lutomirski <luto@kernel.org>
Date: Wed, 21 Nov 2018 15:15:15 +0000
Subject: Re: [PATCH v2 16/15] syscall_get_arch: add "struct task_struct *" argument
Message-Id: <CALCETrV8AJPkZF7TzhXSte_wJgNXH+-s7-tPM-8xjcAfYgzdhg@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20181107042751.3b519062@akathisia>
 <CALCETrV1v-DPRfDRwiH=xn29bxWxiHdZtAH1nw=dsmDtnT0YGQ@mail.gmail.com>
 <20181120001128.GA11300@altlinux.org> <20181121004422.GA29053@altlinux.org>
In-Reply-To: <20181121004422.GA29053@altlinux.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Dmitry V. Levin" <ldv@altlinux.org>
Cc: Linux MIPS Mailing List <linux-mips@linux-mips.org>, linux-ia64@vger.kernel.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, linux-riscv@lists.infradead.org, linux-arch <linux-arch@vger.kernel.org>, linux-s390 <linux-s390@vger.kernel.org>, Paul Moore <paul@paul-moore.com>, linux-hexagon@vger.kernel.org, X86 ML <x86@kernel.org>, Eugene Syromiatnikov <esyr@redhat.com>, Elvira Khabirova <lineprinter@altlinux.org>, arcml <linux-snps-arc@lists.infradead.org>, uclinux-h8-devel@lists.sourceforge.jp, linux-xtensa@linux-xtensa.org, linux-um@lists.infradead.org, linux-m68k@lists.linux-m68k.org, openrisc@lists.librecores.org, Andrew Lutomirski <luto@kernel.org>, linux-arm-kernel <linux-arm-kernel@lists.infradead.org>, linux-c6x-dev@linux-c6x.org, linux-parisc@vger.kernel.org, Oleg Nesterov <oleg@redhat.com>, Eric Paris <eparis@redhat.com>, linux-audit@redhat.comlinux-

On Tue, Nov 20, 2018 at 4:44 PM Dmitry V. Levin <ldv@altlinux.org> wrote:
>
> This argument is required to extend the generic ptrace API
> with PTRACE_GET_SYSCALL_INFO request: syscall_get_arch() is going to be
> called from ptrace_request() along with other syscall_get_* functions
> with a tracee as their argument.
>
> This change partially reverts commit 5e937a9ae913 ("syscall_get_arch:
> remove useless function arguments").
>

Reviewed-by: Andy Lutomirski <luto@kernel.org> # for x86
