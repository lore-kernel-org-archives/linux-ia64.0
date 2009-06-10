From: David Miller <davem@davemloft.net>
Date: Wed, 10 Jun 2009 08:09:15 +0000
Subject: Re: [Patch 4/5] module: trim exception table in module_free()
Message-Id: <20090610.010915.255287284.davem@davemloft.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <200906041800.54696.rusty@rustcorp.com.au>
	<4A278C62.8000801@redhat.com>
	<200906060038.03089.rusty@rustcorp.com.au>
In-Reply-To: <200906060038.03089.rusty@rustcorp.com.au>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: rusty@rustcorp.com.au
Cc: amwang@redhat.com, linux-kernel@vger.kernel.org, jdike@addtoit.com, hch@infradead.org, mingo@elte.hu, akpm@linux-foundation.org, sparclinux@vger.kernel.org, linux-alpha@vger.kernel.org, linux-ia64@vger.kernel.org

From: Rusty Russell <rusty@rustcorp.com.au>
Date: Sat, 6 Jun 2009 00:38:02 +0930

> Sparc32 is unique; it doesn't seem to define ARCH_HAS_SORT_EXTABLE,
> yet it defines its own sort_extable() which overrides the one in lib.
> It doesn't sort, so we have to mark deleted entries instead of
> actually trimming them.
> 
> Inspired-by: Amerigo Wang <amwang@redhat.com>
> Signed-off-by: Rusty Russell <rusty@rustcorp.com.au>

Acked-by: David S. Miller <davem@davemloft.net>
