From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Mon, 10 Dec 2007 22:45:02 +0000
Subject: Re: git pull on ia64 linux tree
Message-Id: <alpine.LFD.0.9999.0712101442490.28293@woody.linux-foundation.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <200504222203.j3MM3fV17003@unix-os.sc.intel.com>
In-Reply-To: <200504222203.j3MM3fV17003@unix-os.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org



On Mon, 10 Dec 2007, Luck, Tony wrote:
>
> This will update the files shown below.
>
> ..
>  16 files changed, 56 insertions(+), 53 deletions(-)

Hmm. It also did:

   mode change 100755 => 100644 arch/ia64/scripts/unwcheck.py

was that really intentional?

Sure, the commit itself:

> Andrew Morton:
>       [IA64] don't assume that unwcheck.py is executable

makes the Makefile work even for a non-executable file for when you use 
inferior tools, but does that mean that we should have thrown away the 
information that it *is* an executable file when not using those inferior 
tools?

		Linus
