From: Jes Sorensen <jes@sgi.com>
Date: Fri, 07 Sep 2007 08:38:07 +0000
Subject: Re: [PATCH 1/1] Allow global purge traslation cache (ptc.g) to be
Message-Id: <46E10DEF.4020500@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200708301338.34246.protasnb@gmail.com>
In-Reply-To: <200708301338.34246.protasnb@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Luck, Tony wrote:
>> So far it appears to me that it will be defined for ia64 somewhere in
>> asm-generic/tlb.h and in asm-ia64/tlb.h as
>> platform_global_tlb_ipi_purge() something, but I'm not sure about
>> that, will have to start digging.
> 
> I'm voting with David on this one ... machvec doesn't look like
> the right mechanism for this (all of the non-sn2 machvecs would
> potentially have to be duplicated to provide ptc.g and !ptc.g
> variants ... that doesn't sound like a good plan).

The reason why I suggested a machvec is to avoid cluttering up the
generic function with something like this. In addition I only see two
machvec's that may potentially get copied, the dig one and the hpzx1
one.

If we start adding clutter to the generic functions we will end up with
a 2-dimensional mesh of things where some is handled machvec style and
then we have local variations within the machvecs. I suspect the Unisys
and HP machines will end up having special machvecs for these machines
anyway.

Cheers,
Jes
