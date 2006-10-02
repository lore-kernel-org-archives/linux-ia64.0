From: "Luck, Tony" <tony.luck@intel.com>
Date: Mon, 02 Oct 2006 17:35:01 +0000
Subject: Re: kexec/kdump and the ia64 test tree
Message-Id: <20061002173501.GA27693@intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200609292146.k8TLkNex005603@agluck-lia64.sc.intel.com>
In-Reply-To: <200609292146.k8TLkNex005603@agluck-lia64.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> overall that plan seems fine to me - though I would have preferred
> a more incremental approach.

There are conflicting opinions on this on LKML ... some people believe
that it is better that the Linux change log represent history as it
should have been ... i.e. clean away all the goofs and mis-steps in
the sub-trees and send Linus the one true patch (or series of patches)
that do exactly what is wanted.  For the case of the white-space cleanup
part of the kexec/kdump patches, I can solidly get behind this opinion:
I can see no benefit to keeping separate patches that first mess-up
the whitespace, and then fix it.

On the other hand ... when there are real code changes involved, there
is definite benefit to preserving the dead-end development paths that
were abandoned (so that future debugging/development efforts at least
have the option to learn from our mistakes).  The removal of
ioc_iova_disable() almost falls into this category ... except that
we have already dropped the places where it was called, so if we
preserve it now, it would just be as the addition and immediate
removal of some dead code ... which looks to have less historical
value.

>                                I will spend some time today checking
> over your patch and see if I can spot any insanity.

Thanks for taking the time to do this.

> On a related note, does/did your ia64-test branch have anything
> of significance in it other than kexec/kdump?

There were a couple of other patches in "test" that I pulled over
to release and sent to Linus.  So kexec is all that is in there right
now.

-Tony
