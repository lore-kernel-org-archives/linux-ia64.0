From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Date: Thu, 04 Sep 2008 22:36:51 +0000
Subject: Re: [PATCH] Correct printk %pF to work on all architectures
Message-Id: <1220567811.4879.85.camel@pasglop>
List-Id: <linux-ia64.vger.kernel.org>
References: <1220473137.3254.29.camel@localhost.localdomain>
	 <alpine.LFD.1.10.0809031419560.3515@nehalem.linux-foundation.org>
	 <1220481754.3254.42.camel@localhost.localdomain>
	 <alpine.LFD.1.10.0809031546310.3515@nehalem.linux-foundation.org>
	 <1220482853.3254.47.camel@localhost.localdomain>
	 <alpine.LFD.1.10.0809031602270.3515@nehalem.linux-foundation.org>
	 <1220484812.3254.59.camel@localhost.localdomain>
	 <alpine.LFD.1.10.0809031636320.3515@nehalem.linux-foundation.org>
	 <1220492616.3254.64.camel@localhost.localdomain>
In-Reply-To: <1220492616.3254.64.camel@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: James Bottomley <James.Bottomley@HansenPartnership.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, linux-arch@vger.kernel.org, linuxppc-dev@ozlabs.org, linux-ia64@vger.kernel.org, Parisc List <linux-parisc@vger.kernel.org>

> Make dereference_function_descriptor() more accommodating by allowing
> architecture overrides.  I put the three overrides (for parisc64, ppc64
> and ia64) in arch/kernel/module.c because that's where the kernel
> internal linker which knows how to deal with function descriptors sits.
> 
> Signed-off-by: James Bottomley <James.Bottomley@HansenPartnership.com>

Acked-by: Benjamin Herrenschmidt <benh@kernel.crashing.org>


