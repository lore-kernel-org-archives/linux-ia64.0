From: Rob Browning <rlb@defaultvalue.org>
Date: Wed, 19 Jul 2006 01:40:07 +0000
Subject: Re: Problem with Guile on ia64 (possibly "getcontext" related)
Message-Id: <87u05eqsnc.fsf@raven.defaultvalue.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <87ac7ajylc.fsf@raven.defaultvalue.org>
In-Reply-To: <87ac7ajylc.fsf@raven.defaultvalue.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Keith Owens <kaos@ocs.com.au> writes:

> Wild guess, based on no data.  Add '__attribute__ ((returns_twice))' to
> the definition of ia64_getcontext.  That should remove the need to use
> setjmp.

That also seems to fix the crash.

So would it be correct to say that the likely problem is just that
because Guile calls getcontext via asm, gcc doesn't know that the call
needs to be handled specially?

Thanks
-- 
Rob Browning
rlb @defaultvalue.org and @debian.org; previously @cs.utexas.edu
GPG starting 2002-11-03 = 14DD 432F AE39 534D B592  F9A0 25C8 D377 8C7E 73A4
