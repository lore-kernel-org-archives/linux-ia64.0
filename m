From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date: Fri, 24 Oct 2003 18:24:48 +0000
Subject: Re: PATCH 2.4.23-pre6 add kmap_types.h for CONFIG_CRYPTO
Message-Id: <marc-linux-ia64-106701990204246@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106633278923482@msgid-missing>
In-Reply-To: <marc-linux-ia64-106633278923482@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thursday 23 October 2003 4:28 pm, Keith Owens wrote:
> Letting code play
> with km types just makes that code more fragile.  crypto wants to use
> different km types based on context (softirq or not).  If crypto needs
> that functionallity then I expect other code to need it as well, which
> means the facility should be part of kmap, not implemented by each code
> area.

Can you give an example of what such a new kmap interface would
look like?  The crypto code looks reasonable to me, and I don't
know enough about kmap to guess what abstraction you might have
in mind.

I agree it's not optimal to define the KM_ enums in highmem.h
for the non-highmem case, but I think it's better than having
to use #ifdef CONFIG_HIGHMEM in the crypto code.

You seem to be concerned about the fact that my patch touches
so many architectures, but you said earlier:

> That is an error in crypto/internal.h.  Nothing should include
> asm/kmap_types.h directly, they should include linux/highmem.h and let
> that decide if the arch needs kmap or not.

So I assume that if you did a complete patch it would
	1) Remove "#include <asm/kmap_types.h" from crypto/internal.h
	2) Remove "#include <asm/kmap_types.h" from fs/aio.c
	3) Add "#include <asm/kmap_types.h" to include/linux/highmem.h
	   (under #ifdef CONFIG_HIGHMEM).
	4) Remove kmap_types.h from non-highmem architectures, since
	   they're no longer referenced.

Which means that your approach would touch just as many arches.

Bjorn

