From: Matthew Wilcox <willy@debian.org>
Date: Sun, 28 Sep 2003 16:27:52 +0000
Subject: Wrong flags for gate.o
Message-Id: <marc-linux-ia64-106476649513576@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


  CPP     arch/ia64/kernel/gate.lds.s
  AS      arch/ia64/kernel/gate.o
  GATE arch/ia64/kernel/gate.so
  AS      arch/ia64/kernel/gate-data.o
arch/ia64/kernel/gate-data.S: Assembler messages:
arch/ia64/kernel/gate-data.S:1: Warning: setting incorrect section attributes for .data.gate
  GATE arch/ia64/kernel/gate-syms.o

-- 
"It's not Hollywood.  War is real, war is primarily not about defeat or
victory, it is about death.  I've seen thousands and thousands of dead bodies.
Do you think I want to have an academic debate on this subject?" -- Robert Fisk
