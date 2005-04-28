From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Thu, 28 Apr 2005 20:43:14 +0000
Subject: Re: write_unlock: replace clear_bit with byte store
Message-Id: <17009.19170.812514.281553@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.58.0504281329150.23584@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.58.0504281329150.23584@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Thu, 28 Apr 2005 13:32:35 -0700 (PDT), Christoph Lameter <clameter@engr.sgi.com> said:

  Christoph> #define _raw_write_unlock(x)								\
  Christoph> ({											\
  Christoph> -	smp_mb__before_clear_bit();	/* need barrier before releasing lock... */	\
  Christoph> -	clear_bit(31, (x));								\
  Christoph> +	u8 *y = (u8 *)x;								\
  Christoph> +	smp_wmb();			/* need barrier before releasing lock... */	\
  Christoph> +	y[3] = 0;									\
  Christoph> })

I'm unsure if it's a good idea to reduce the counter size.
Independent of that: using a name like "y" in a macro is bound to
cause name collisions so it's a big no-no.  Then why not declare
"y" as a "volatile u8 *" so you can avoid the explicit smp_wmb()?
This is ia64-specific code after all.

	--david

