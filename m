From: William Lee Irwin III <wli@holomorphy.com>
Date: Thu, 25 Sep 2003 07:14:18 +0000
Subject: Re: [Lse-tech] CPUSET Proposal
Message-Id: <marc-linux-ia64-106447400909735@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106442121824485@msgid-missing>
In-Reply-To: <marc-linux-ia64-106442121824485@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, 24 Sep 2003 23:57:10 -0700, David Mosberger <davidm@linux.hpl.hp.com> said:
David> I wasn't suggesting that x86 is limited to 8-way, I was
David> wondering how many > 8-way x86 Linux machines are actually
David> out there.  I wasn't even being facetious---just curious.

On Thu, Sep 25, 2003 at 12:07:03AM -0700, David Mosberger wrote:
> Incidentally, the first "big" SMP machine I had access to was some
> sort of Sequent (S81/10?), with ~12 80386 CPUs (yes, that was a long
> time ago... ;-).

Aha, I've been on S-81's myself. Those definitely predated APIC's.
I think they used the SLIC or whatever the precursor to the CSLIC was
for an interrupt controller, and I'm sure there's a Sequent historian
around somewhere to correct me if my memory's (which wouldn't have been
of kernel hacking back then) failed me. =)


-- wli
