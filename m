From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Thu, 09 Oct 2003 20:29:54 +0000
Subject: Re: Wrong flags for gate.o
Message-Id: <marc-linux-ia64-106573199519344@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Sun, 28 Sep 2003 17:27:52 +0100, Matthew Wilcox <willy@debian.org> said:

  Matthew> CPP     arch/ia64/kernel/gate.lds.s
  Matthew> AS      arch/ia64/kernel/gate.o
  Matthew> GATE arch/ia64/kernel/gate.so
  Matthew> AS      arch/ia64/kernel/gate-data.o
  Matthew> arch/ia64/kernel/gate-data.S: Assembler messages:
  Matthew> arch/ia64/kernel/gate-data.S:1: Warning: setting incorrect section attributes for .data.gate
  Matthew> GATE arch/ia64/kernel/gate-syms.o

I cannot reproduce this (with as v2.13.90) and don't know why your
assembler is complaining.

	--david
