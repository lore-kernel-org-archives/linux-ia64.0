From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Wed, 03 Sep 2008 21:22:36 +0000
Subject: Re: [PATCH] Correct printk %pF to work on all architectures
Message-Id: <alpine.LFD.1.10.0809031419560.3515@nehalem.linux-foundation.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <1220473137.3254.29.camel@localhost.localdomain>
In-Reply-To: <1220473137.3254.29.camel@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: James Bottomley <James.Bottomley@HansenPartnership.com>
Cc: linux-arch@vger.kernel.org, Parisc List <linux-parisc@vger.kernel.org>, linux-ia64@vger.kernel.org, linuxppc-dev@ozlabs.org



On Wed, 3 Sep 2008, James Bottomley wrote:
> 
> Make dereference_function_descriptor() more accommodating by allowing
> architecture overrides.

Don't do it like this.

We don't want some stupid useless weak function that is empty on all sane 
platforms.

Just do

	.. declare or create an inline 'parisc_function_descriptor()' ..

	#define dereference_function_descriptor(p) parisc_function_descriptor(p)

in some arch header file. And then use

	#ifndef dereference_function_descriptor
	#define dereference_function_descriptor(p) (p)
	#endif

in the generic code, so that sane architectures don't need to do anything 
at all.

		Linus
