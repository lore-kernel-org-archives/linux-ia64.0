From: Rick Jones <rick.jones2@hp.com>
Date: Wed, 22 Oct 2008 17:31:53 +0000
Subject: Re: [PATCH 0/2] enable irqs when waiting for rwlocks
Message-Id: <48FF6389.9050408@hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1224664414.4430.33.camel@elijah.suse.cz>
In-Reply-To: <1224664414.4430.33.camel@elijah.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Petr Tesarik <ptesarik@suse.cz>
Cc: linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, tee@sgi.com

Petr Tesarik wrote:
> Hello,
> 
> SGI has observed that on large systems, interrupts are not serviced for
> a long period of time when waiting for a rwlock. The following patch
> series re-enables irqs while waiting for the lock, resembling the code
> which is already there for spinlocks.

Perhaps I'm just out in left field, but that (and the similar behaviour 
for obtaining a spinlock?) feels like treating a symptom rather than a 
root cause where the root cause would appear to be long lock hold 
times/contention?

rick jones
