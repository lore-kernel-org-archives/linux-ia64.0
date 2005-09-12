From: Linus Torvalds <torvalds@osdl.org>
Date: Mon, 12 Sep 2005 03:24:19 +0000
Subject: RE: git pull on ia64 linux tree
Message-Id: <Pine.LNX.4.58.0509112021070.3242@g5.osdl.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <200504222203.j3MM3fV17003@unix-os.sc.intel.com>
In-Reply-To: <200504222203.j3MM3fV17003@unix-os.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org



On Sun, 11 Sep 2005, Luck, Tony wrote:
> >>
> >>Wazzup?
> >
> >http://lkml.org/lkml/2005/9/8/315/.
> 
> Does it help to lower your unhappiness level?

Not in the least.

> Can you see a better way to do this?

I still don't even see the point in the first place. 

Everything Keith says about MCA/INIT is true on x86 about NMI's. That has 
nothing to do with "currently runnable process". And it sure as hell 
doesn't mean that you'd _change_ the kernel notion of what the currently 
runnable process is.

		Linus
