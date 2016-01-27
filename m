From: David Howells <dhowells@redhat.com>
Date: Wed, 27 Jan 2016 14:57:07 +0000
Subject: Re: [PATCH] documentation: Add disclaimer
Message-Id: <15882.1453906627@warthog.procyon.org.uk>
List-Id: <linux-ia64.vger.kernel.org>
References: <20160127083546.GJ6357@twins.programming.kicks-ass.net> <5696BA6E.4070508@imgtec.com> <20160114120445.GB15828@arm.com> <56980145.5030901@imgtec.com> <20160114204827.GE3818@linux.vnet.ibm.com> <56981212.7050301@imgtec.com> <20160114222046.GH3818@linux.vnet.ibm.com> <20160126102402.GE6357@twins.programming.kicks-ass.net> <20160126103200.GI6375@twins.programming.kicks-ass.net> <20160126110053.GA21553@arm.com> <20160126201143.GV4503@linux.vnet.ibm.com>
In-Reply-To: <20160127083546.GJ6357@twins.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Peter Zijlstra <peterz@infradead.org>
Cc: dhowells@redhat.com, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Will Deacon <will.deacon@arm.com>, Leonid Yegoshin <Leonid.Yegoshin@imgtec.com>, "Michael S. Tsirkin" <mst@redhat.com>, linux-kernel@vger.kernel.org, Arnd Bergmann <arnd@arndb.de>, linux-arch@vger.kernel.org, Andrew Cooper <andrew.cooper3@citrix.com>, Russell King - ARM Linux <linux@arm.linux.org.uk>, virtualization@lists.linux-foundation.org, Stefano Stabellini <stefano.stabellini@eu.citrix.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, "H. Peter Anvin" <hpa@zytor.com>, Joe Perches <joe@perches.com>, David Miller <davem@davemloft.net>, linux-ia64@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, sparclinux@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-metag@vger.kernel.org, linux-mips@linux-mips.org, x86@kernel.org, user-mode-linu

Peter Zijlstra <peterz@infradead.org> wrote:

> +=====
> +DISCLAIMER
> +=====
> +
> +This document is not a specification; it is intentionally (for the sake of
> +brevity) and unintentionally (due to being human) incomplete. This document is
> +meant as a guide to using the various memory barriers provided by Linux, but
> +in case of any doubt (and there are many) please ask.
> +
> +I repeat, this document is not a specification of what Linux expects from
> +hardware.

The purpose of this document is twofold:

 (1) to specify the minimum functionality that one can rely on for any
     particular barrier, and

 (2) to provide a guide as to how to use the barriers that are available.

Note that an architecture can provide more than the minimum requirement for
any particular barrier, but if the barrier provides less than that, it is
incorrect.

Note also that it is possible that a barrier may be a no-op for an
architecture because the way that arch works renders an explicit barrier
unnecessary in that case.

> +

Can you bung an extra blank line in here if you have to redo this at all?

> +====
> +CONTENTS
> +====
>  
>   (*) Abstract memory access model.
>  

David
