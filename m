From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Thu, 04 Dec 2003 22:49:49 +0000
Subject: Re: can't boot 2.6.0-test11
Message-Id: <marc-linux-ia64-107057901209426@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-107057525104512@msgid-missing>
In-Reply-To: <marc-linux-ia64-107057525104512@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Thu, 4 Dec 2003 14:06:29 -0800, Stephane Eranian <eranian@hpl.hp.com> said:

  Stephane> I saw your E-mail but I just did a bk pull frmo Linus's
  Stephane> tree and I can't even get my kernel to build using
  Stephane> gcc-3.3.2. I get a lot of unwind related errors:

  Stephane> arch/ia64/kernel/entry.S: Assembler messages:
  Stephane> arch/ia64/kernel/entry.S:118: Error: Operand to .fframe must be a constant

That's probably because the offsets.h file wasn't properly updated in your
tree (the kbuild environment is supposed to build it).

When in doubt, this is a good place to check the status of ia64 builds
from Linus' tree:

	http://www.gelato.unsw.edu.au/kerncomp/

  --david
