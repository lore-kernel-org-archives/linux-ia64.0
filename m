From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Tue, 10 Feb 2004 01:28:14 +0000
Subject: Re: unwabi mismatch in 2.4.X kernels breaks oops call trace (unwind)
Message-Id: <16424.13230.574368.242997@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1076374136.10372.3.camel@peas.bobm>
In-Reply-To: <1076374136.10372.3.camel@peas.bobm>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Mon, 09 Feb 2004 17:48:57 -0700, Bob Montgomery <bob.montgomery@hp.com> said:

  Bob> So my question is: Is there a compelling reason to change the
  Bob> abi number from 0 to 3 in 2.4.X kernels?

It must change iff the syscall-streamlining patch is applied, since
that patch changes the format of the pt-regs structure.

  Bob> Is there an outside tool that cares

Libunwind and, for example, Ski definitely care.

	--david
