From: Keith Owens <kaos@ocs.com.au>
Date: Thu, 23 Oct 2003 22:28:16 +0000
Subject: Re: PATCH 2.4.23-pre6 add kmap_types.h for CONFIG_CRYPTO
Message-Id: <marc-linux-ia64-106694813703040@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106633278923482@msgid-missing>
In-Reply-To: <marc-linux-ia64-106633278923482@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, 23 Oct 2003 16:15:56 -0600, 
Bjorn Helgaas <bjorn.helgaas@hp.com> wrote:
>On Thursday 23 October 2003 3:04 pm, Keith Owens wrote:
>> I disagree with this fix.  All uses of KM_ variables are restricted to
>> headers that make their use conditional on CONFIG_HIGHMEM.
>
>It's not true that all uses of KM_ variables are restricted to headers.
>As one counter-example, file_read_actor() in mm/filemap.c does this:
>
>	kaddr = kmap_atomic(page, KM_USER0);
>
>I guess your argument is that KM_ variables should *only* be
>used in places where they'll never be evaluated, i.e., as
>arguments to kmap_atomic() and kunmap_atomic().

Right.

>I think that if you can pass KM_USER0 to a function, you ought
>to be able to copy KM_USER0 somewhere and pass the copy to
>the function.  Otherwise we'll just have to keep explaining
>this funny wart on the kmap interface.

Disagree.  kmap is currently nicely encapsulated.  Letting code play
with km types just makes that code more fragile.  crypto wants to use
different km types based on context (softirq or not).  If crypto needs
that functionallity then I expect other code to need it as well, which
means the facility should be part of kmap, not implemented by each code
area.

Failing that, crypto should only use km types on builds that have
CONFIG_HIGHMEM defined.

>I only changed so many architectures because the whole point was to
>avoid requiring a dummy kmap_types.h file if you don't use highmem.
>So I just removed the now-unnecessary kmap_types.h files, and I
>assume you would do the same.  (Although you didn't mention changes
>to include/linux/highmem.h and fs/aio.c to remove generic knowledge
>of <asm/kmap_types.h>, so I could be misunderstanding your proposal.)

Fix crypto to test CONFIG_HIGHMEM and no other changes are required.

