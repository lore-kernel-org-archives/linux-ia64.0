From: "Boehm, Hans" <hans_boehm@hp.com>
Date: Wed, 23 Jan 2002 17:46:48 +0000
Subject: RE: [Linux-ia64] native ia64 32-bits compile & run on linux-ia64?
Message-Id: <marc-linux-ia64-105590698805919@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805893@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805893@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

The tradeoffs here are very different for an OS/platform that previously
provided an ILP32 ABI with an existing application base (e.g. Solaris,
Linux/ppc), and one that didn't.  In the former case, I think the experience
has been that it's very expensive to support the second (or third) ABI, but
it's completely impractical to drop support for the existing application
base, so there is no way around the cost of multiple ABIs if you want to
support 64-bit pointers.  Linux/Itanium is not one of these, at least if you
ignore the X86 ABI.  We have a choice.  And I don't believe that in the long
run the benefit will come close to the cost of an ILP32 native ABI,
eventhough it might help some of us in the short run.  Even for open source
libraries, another ABI adds significant testing overhead, etc.

The other Itanium operating systems present somewhat different tradeoffs.
All existing PORTABLE Linux applications were by definition already 64-bit
clean, since Linux/Alpha provided only a 64-bit ABI.  In the case of HP/UX,
I suspect at least some of the ILP32 infrastructure was needed for PA-RISC
binary emulation anyway.  (I'm not aware of what really went into the
decision for HP/UX, so I'm just speculating ...)

Hans

-------------------------

"David" = David Mosberger <davidm@hpl.hp.com> writes:
David> I think one point that hasn't been made so far is that we
David> actively discourage supporting an ILP32 data model for IA-64
David> Linux to avoid splitting ia64 linux into two different worlds
David> (32-bit and 64-bit world).  If we supported ILP32, it's very
David> likely that some ISVs will decide to provide *only* 32-bit
David> libraries, which could in turn force other ISVs to stay with
David> 32-bit just because they couldn't get the pre-requisite 64-bit
David> libraries.  My understanding is that IRIX suffered from this
David> effect.

Jes Sorenson wrote:

Very good point, and even if we went down that road one could argue weshould
only go for IP32 with long's being 64 bit.

Francois-Xavier Kowalski wrote:

I see the drawback...  :-D  But maybe Linux provides enough open-source
alternatives to existing ISV libraries to limit the number of ISV's impacted
by this kind of forced limitation...?

BTW, do you know what is the choice on Linux/ppc64 vs. the previous
Linux/ppc implementation on the same topic(data-model sizes)?


