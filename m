From: Jes Sorensen <jes@trained-monkey.org>
Date: Tue, 22 Jan 2002 19:37:25 +0000
Subject: Re: [Linux-ia64] native ia64 32-bits compile & run on linux-ia64?
Message-Id: <marc-linux-ia64-105590698805915@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805893@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805893@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> "David" = David Mosberger <davidm@hpl.hp.com> writes:

David> I think one point that hasn't been made so far is that we
David> actively discourage supporting an ILP32 data model for IA-64
David> Linux to avoid splitting ia64 linux into two different worlds
David> (32-bit and 64-bit world).  If we supported ILP32, it's very
David> likely that some ISVs will decide to provide *only* 32-bit
David> libraries, which could in turn force other ISVs to stay with
David> 32-bit just because they couldn't get the pre-requisite 64-bit
David> libraries.  My understanding is that IRIX suffered from this
David> effect.

Very good point, and even if we went down that road one could argue we
should only go for IP32 with long's being 64 bit.

Just say no ;)

Jes

