From: Andi Kleen <ak@suse.de>
Date: Wed, 28 Jan 2004 21:09:21 +0000
Subject: Re: [RFC/PATCH, 2/4] readX_check() performance evaluation
Message-Id: <20040128220921.7ba0bb78.ak@suse.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <00a301c3e541$c13a6350$2987110a@lsd.css.fujitsu.com>
	<Pine.LNX.4.58.0401271847440.10794@home.osdl.org>
	<20040128182003.GL11844@parcelfarce.linux.theplanet.co.uk>
	<Pine.LNX.4.58.0401281129570.28145@home.osdl.org>
	<20040128204049.627e6312.ak@suse.de>
	<Pine.LNX.4.58.0401281205250.28145@home.osdl.org>
	<20040128211554.0cc890fb.ak@suse.de>
	<Pine.LNX.4.58.0401281221320.28145@home.osdl.org>
In-Reply-To: <Pine.LNX.4.58.0401281221320.28145@home.osdl.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Linus Torvalds <torvalds@osdl.org>
Cc: willy@debian.org, ishii.hironobu@jp.fujitsu.com, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org

On Wed, 28 Jan 2004 12:28:56 -0800 (PST)
Linus Torvalds <torvalds@osdl.org> wrote:

> 
> Alternatively, if you get a lot of information at MCE time (CPU that did
> the access + some device data), just queue up the information in a per-CPU
> queue. You don't have to worry about overflow - you can just drop if if 

That assumes that the access happened with preempt off ?

That's fine if it's guaranteed that the MCE still happened inside 
readl/writel. But if it's delayed longer for some reason there is no guarantee 
that you can find back to the CPU that caused the fault.

Putting it into the pci_dev and using RCU would be probably better.

-Andi
