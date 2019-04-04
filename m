From: Steven Rostedt <rostedt@goodmis.org>
Date: Thu, 04 Apr 2019 21:06:08 +0000
Subject: Re: [PATCH 5/6 v3] syscalls: Remove start and number from syscall_get_arguments() args
Message-Id: <20190404170608.25cadc7d@gandalf.local.home>
List-Id: <linux-ia64.vger.kernel.org>
References: <20190401134104.676620247@goodmis.org>
        <20190401134421.278590567@goodmis.org>
        <20190404181758.GA8071@altlinux.org>
In-Reply-To: <20190404181758.GA8071@altlinux.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Dmitry V. Levin" <ldv@altlinux.org>
Cc: linux-kernel@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, Ingo Molnar <mingo@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Andy Lutomirski <luto@amacapital.net>, Roland McGrath <roland@hack.frob.com>, Oleg Nesterov <oleg@redhat.com>, linux-arch@vger.kernel.org, Peter Zijlstra <peterz@infradead.org>, Thomas Gleixner <tglx@linutronix.de>, "Gustavo A. R. Silva" <gustavo@embeddedor.com>, Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, "H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org, Dominik Brodowski <linux@dominikbrodowski.net>, Andy Lutomirski <luto@kernel.org>, Kees Cook <keescook@chromium.org>, "Eric W. Biederman" <ebiederm@xmission.com>, Palmer Dabbelt <palmer@sifive.com>, Dave Martin <dave.martin@arm.c>

On Thu, 4 Apr 2019 21:17:58 +0300
"Dmitry V. Levin" <ldv@altlinux.org> wrote:

> There are several places listed below where I'd prefer to see more readable
> equivalents, but feel free to leave it to respective arch maintainers.

I was going to do similar changes, but figured I'd do just that (let
the arch maintainers further optimize the code). I made this more about
fixing the interface and less about the optimization and clean ups that
it can allow.

-- Steve
