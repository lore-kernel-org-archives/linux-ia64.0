From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Fri, 07 Nov 2003 23:58:03 +0000
Subject: Re: [Patch] Fix IA64 compilation with separate build tree.
Message-Id: <marc-linux-ia64-106825029824507@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106790402625772@msgid-missing>
In-Reply-To: <marc-linux-ia64-106790402625772@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Tue, 4 Nov 2003 10:59:07 +1100, Peter Chubb <peterc@gelato.unsw.edu.au> said:

  Peter> Hi David,
  Peter> The appended patch (as we discussed before) is necessary to allow
  Peter> separate source and build trees for IA64.  Without it, offsets.h
  Peter> cannot be built if you do, say,
  Peter> make O=../build/linux-2.5-ia64
  Peter> and the gas checks never succeed.

Argh, I thought this was already in my tree but apparently it is not.
Since it's hardly a critical bug-fix, could you retransmit for 2.6.1?

Thanks,

	--david
