From: Grant Grundler <iod00d@hp.com>
Date: Wed, 09 Mar 2005 17:38:50 +0000
Subject: Re: conflicting per_cpu_init() defines on non-SMP
Message-Id: <20050309173850.GC10338@esmail.cup.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1110344998.9344.9.camel@localhost>
In-Reply-To: <1110344998.9344.9.camel@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, Mar 08, 2005 at 10:09:58PM -0700, dann frazier wrote:
> Is this the right way to approach a patch to fix this?

It looks right. But I'd expect arch/ia64/mm/discontig.c to use whats
in the header file so everyone is using the same definition.

> +#ifdef CONFIG_SMP
>  void *per_cpu_init(void)
...

ie move that bit to asm-ia64/percpu.h

grant
