From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date: Thu, 23 Oct 2003 22:15:56 +0000
Subject: Re: PATCH 2.4.23-pre6 add kmap_types.h for CONFIG_CRYPTO
Message-Id: <marc-linux-ia64-106694737602277@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106633278923482@msgid-missing>
In-Reply-To: <marc-linux-ia64-106633278923482@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thursday 23 October 2003 3:04 pm, Keith Owens wrote:
> I disagree with this fix.  All uses of KM_ variables are restricted to
> headers that make their use conditional on CONFIG_HIGHMEM.

It's not true that all uses of KM_ variables are restricted to headers.
As one counter-example, file_read_actor() in mm/filemap.c does this:

	kaddr = kmap_atomic(page, KM_USER0);

I guess your argument is that KM_ variables should *only* be
used in places where they'll never be evaluated, i.e., as
arguments to kmap_atomic() and kunmap_atomic().

I think that if you can pass KM_USER0 to a function, you ought
to be able to copy KM_USER0 somewhere and pass the copy to
the function.  Otherwise we'll just have to keep explaining
this funny wart on the kmap interface.

> crypto is
> the only expection and the correct fix is to change crypto to test
> CONFIG_HIGHMEM, not to change every architecture.

I only changed so many architectures because the whole point was to
avoid requiring a dummy kmap_types.h file if you don't use highmem.
So I just removed the now-unnecessary kmap_types.h files, and I
assume you would do the same.  (Although you didn't mention changes
to include/linux/highmem.h and fs/aio.c to remove generic knowledge
of <asm/kmap_types.h>, so I could be misunderstanding your proposal.)

Bjorn

