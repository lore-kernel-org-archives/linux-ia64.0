From: Stephane Eranian <eranian@hpl.hp.com>
Date: Fri, 16 Jan 2004 23:37:43 +0000
Subject: Re: GL-related crash w/ X 4.3 & kernel 2.6
Message-Id: <20040116233743.GD6176@frankl.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Matthew,

We got 3d acceleration to work just fine on a ZX2000 with 2.6.1
and Debian/testing. Flightgear works fine, no lock ups. 

The video card is a Radeon 7200 (R100 QD), we've loaded the hp_agp 
and radeon modules.

Have you tried with 2.6.1?


On Mon, Dec 29, 2003 at 07:41:44PM +0000, Matthew Wilcox wrote:
> 
> I'm not terribly familiar with how X and the kernel interact, so please
> bear with me if I used the wrong terms.
> 
> The slow way to reproduce the problem:
> 	Run glxgears and do other things.  Eventually X will stop responding.
> 	Took a few hours.
> 
> The fast way:
> 	Run flightgear.  This typically locks up within a minute or two.
> 
> I can still ssh into the machine.  Running top typically shows either
> X or the application hogging 99% of the CPU.  The mouse pointer still
> moves on the screen, but the focus will not change to any other X app.
> The window manager does not respond.
> 
> The machine is a zx2000 workstation with a Radeon 7000/VE card.  Kernel is
> 2.6.0 plus some additional changes (mostly jgarzik's latest netdrivers
> patch) [but it's happened with other 2.6 kernels].  The X server is
> Debian's 4.3.0-0pre1v5 [but it's happened with other 4.3.0 releases].
> 
> First, can anyone else reproduce this or not, and with what other
> combinations of X, kernel, hardware, etc?
> 
> Second, since neither strace nor gdb is willing to cooperate in helping
> to track this down, can anyone more knowledgable than I about the ways
> of GL suggest how to start debugging this?
> 
> -- 
> "Next the statesmen will invent cheap lies, putting the blame upon 
> the nation that is attacked, and every man will be glad of those
> conscience-soothing falsities, and will diligently study them, and refuse
> to examine any refutations of them; and thus he will by and by convince 
> himself that the war is just, and will thank God for the better sleep 
> he enjoys after this process of grotesque self-deception." -- Mark Twain
> -
> To unsubscribe from this list: send the line "unsubscribe linux-ia64" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

-- 

-Stephane
