From: Matthew Wilcox <willy@debian.org>
Date: Mon, 29 Dec 2003 19:41:44 +0000
Subject: GL-related crash w/ X 4.3 & kernel 2.6
Message-Id: <marc-linux-ia64-107272704926812@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


I'm not terribly familiar with how X and the kernel interact, so please
bear with me if I used the wrong terms.

The slow way to reproduce the problem:
	Run glxgears and do other things.  Eventually X will stop responding.
	Took a few hours.

The fast way:
	Run flightgear.  This typically locks up within a minute or two.

I can still ssh into the machine.  Running top typically shows either
X or the application hogging 99% of the CPU.  The mouse pointer still
moves on the screen, but the focus will not change to any other X app.
The window manager does not respond.

The machine is a zx2000 workstation with a Radeon 7000/VE card.  Kernel is
2.6.0 plus some additional changes (mostly jgarzik's latest netdrivers
patch) [but it's happened with other 2.6 kernels].  The X server is
Debian's 4.3.0-0pre1v5 [but it's happened with other 4.3.0 releases].

First, can anyone else reproduce this or not, and with what other
combinations of X, kernel, hardware, etc?

Second, since neither strace nor gdb is willing to cooperate in helping
to track this down, can anyone more knowledgable than I about the ways
of GL suggest how to start debugging this?

-- 
"Next the statesmen will invent cheap lies, putting the blame upon 
the nation that is attacked, and every man will be glad of those
conscience-soothing falsities, and will diligently study them, and refuse
to examine any refutations of them; and thus he will by and by convince 
himself that the war is just, and will thank God for the better sleep 
he enjoys after this process of grotesque self-deception." -- Mark Twain
