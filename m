From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Tue, 17 Dec 2002 03:25:39 +0000
Subject: Re: [Linux-ia64] Re: gas generates incorrect ia64 unwind rlen values
Message-Id: <marc-linux-ia64-105590709805593@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805569@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805569@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

  Keith> I used gcc 2.96 20000731 (Red Hat Linux 7.1 2.96-101) to
  Keith> convert traps.c to traps.S, then extracted the headers and
  Keith> ia64_fault for testing against gas.  traps.S only has one
  Keith> body.  I wanted to avoid dumping 530+ lines to the list but
  Keith> ...

  Keith> Interesting that a different gcc which generates two bodies
  Keith> gets valid unwind data, but this code with only one body
  Keith> generates invalid unwind data.  David, what does your unwind
  Keith> data look like after assembling this code?

Why do you insist on re-discovering old bugs?  For the code in
question, the problem is caused by the jump-table generated for the
switch-statement.  gcc 2.9x placed jump-tables in the text section,
which violates the ia64 ABI and also confuses the assembler.

	--david

