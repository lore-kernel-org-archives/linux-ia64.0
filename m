From: =?utf-8?B?QmrDtnJuIFTDtnBlbA==?= <bjorn@kernel.org>
Date: Mon, 06 Feb 2023 20:06:31 +0000
Subject: Re: [PATCH 09/10] riscv: fix livelock in uaccess
Message-Id: <87h6vyimns.fsf@all.your.base.are.belong.to.us>
List-Id: <linux-ia64.vger.kernel.org>
References: <Y9lz6yk113LmC9SI@ZenIV> <Y9l02DvS6CYThTEG@ZenIV>
In-Reply-To: <Y9l02DvS6CYThTEG@ZenIV>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
To: Al Viro <viro@zeniv.linux.org.uk>, linux-arch@vger.kernel.org
Cc: linux-alpha@vger.kernel.org, linux-ia64@vger.kernel.org, linux-hexagon@vger.kernel.org, linux-m68k@lists.linux-m68k.org, Michal Simek <monstr@monstr.eu>, Dinh Nguyen <dinguyen@kernel.org>, openrisc@lists.librecores.org, linux-parisc@vger.kernel.org, linux-riscv@lists.infradead.org, sparclinux@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, Mark Rutland <mark.rutland@arm.com>

Al Viro <viro@zeniv.linux.org.uk> writes:

> riscv equivalent of 26178ec11ef3 "x86: mm: consolidate VM_FAULT_RETRY handling"
> If e.g. get_user() triggers a page fault and a fatal signal is caught, we might
> end up with handle_mm_fault() returning VM_FAULT_RETRY and not doing anything
> to page tables.  In such case we must *not* return to the faulting insn -
> that would repeat the entire thing without making any progress; what we need
> instead is to treat that as failed (user) memory access.
>
> Signed-off-by: Al Viro <viro@zeniv.linux.org.uk>

Reproduced with Mark's userland program -- thanks!

Tested-by: Björn Töpel <bjorn@kernel.org>
