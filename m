From: Toke =?utf-8?Q?H=C3=B8iland-J=C3=B8rgensen?= <toke@redhat.com>
Date: Mon, 06 Jun 2022 07:53:32 +0000
Subject: Re: [PATCH] ia64: fix sparse warnings with cmpxchg() & xchg()
Message-Id: <871qw2xm6b.fsf@toke.dk>
List-Id: <linux-ia64.vger.kernel.org>
References: <87h7547k8c.fsf@toke.dk>
 <20220605160738.79736-1-luc.vanoostenryck@gmail.com>
In-Reply-To: <20220605160738.79736-1-luc.vanoostenryck@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
To: Luc Van Oostenryck <luc.vanoostenryck@gmail.com>, Arnd Bergmann <arnd@arndb.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, "Paul E. McKenney" <paulmck@kernel.org>, Luc Van Oostenryck <luc.vanoostenryck@gmail.com>, kernel test robot <lkp@intel.com>

Luc Van Oostenryck <luc.vanoostenryck@gmail.com> writes:

> On IA64, new sparse's warnings where issued after fixing
> some __rcu annotations in kernel/bpf/.
>
> These new warnings are false positives and appear on IA64 because
> on this architecture, the macros for cmpxchg() and xchg() make
> casts that ignore sparse annotations.
>
> This patch contains the minimal patch to fix this issue:
> adding a missing cast and some missing '__force'.
>
> Link: https://lore.kernel.org/r/20220601120013.bq5a3ynbkc3hngm5@mail
> Reported-by: kernel test robot <lkp@intel.com>
> Cc: Toke Høiland-Jørgensen <toke@redhat.com>
> Signed-off-by: Luc Van Oostenryck <luc.vanoostenryck@gmail.com>

Ah, thank you for taking care of this! :)

Acked-by: Toke Høiland-Jørgensen <toke@redhat.com>
