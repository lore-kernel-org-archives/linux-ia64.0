From: "Luck, Tony" <tony.luck@intel.com>
Date: Thu, 02 Aug 2007 17:16:14 +0000
Subject: RE: ia64 mmu_gather question
Message-Id: <617E1C2C70743745A92448908E030B2A0211B114@scsmsx411.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1186026055.5495.585.camel@localhost.localdomain>
In-Reply-To: <1186026055.5495.585.camel@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

> I was thinking about a case where the TLB is shared (SMT) between linux
> logical CPUs (threads) but ia64 is not SMT right ? Thus the TLB is
> split ,and the "other" CPU can't see the stale translation... should be
> allright then.

Montecito is SMT, and the threads do share the TLB resources in that
there are a fixed number of TLB TC slots that are dynamically shared
between threads. But entries in the TLB have their virtual addresses tagged
with a thread identifier, so an entry inserted by one thread cannot
be used by another thread.

See sections 2.4.3.1.1 and 2.4.3.1.2 in "Dual-Core Update to the Intel=AE
Itanium=AE 2 Processor Reference Manual"
  http://download.intel.com/design/Itanium2/manuals/30806501.pdf

-Tony
