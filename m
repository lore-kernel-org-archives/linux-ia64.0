From: Peter Chubb <peter@chubb.wattle.id.au>
Date: Fri, 04 Jul 2003 22:01:01 +0000
Subject: Re: Using Linus's tree for IA64.
Message-Id: <marc-linux-ia64-105735607317270@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105733106329649@msgid-missing>
In-Reply-To: <marc-linux-ia64-105733106329649@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> "Matthew" = Matthew Wilcox <willy@debian.org> writes:

Matthew> The idea of using Linus' tree for ia64 appeals to me, so I
Matthew> tried it ...
Matthew> It's reproducable, FWIW.  Were you trying on a serial console
Matthew> or a graphical console?

Serial console.  The AGP code needs work; you may be OK if you disable
in-kernel support for AGP.


--
Dr Peter Chubb  http://www.gelato.unsw.edu.au  peterc AT gelato.unsw.edu.au
You are lost in a maze of BitKeeper repositories,   all slightly different.
