From: Linus Torvalds <torvalds@osdl.org>
Date: Wed, 28 Jan 2004 22:21:40 +0000
Subject: Re: [RFC/PATCH, 2/4] readX_check() performance evaluation
Message-Id: <Pine.LNX.4.58.0401281420430.28145@home.osdl.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <00a301c3e541$c13a6350$2987110a@lsd.css.fujitsu.com>
 <Pine.LNX.4.58.0401271847440.10794@home.osdl.org>
 <20040128182003.GL11844@parcelfarce.linux.theplanet.co.uk>
 <Pine.LNX.4.58.0401281129570.28145@home.osdl.org> <20040128204049.627e6312.ak@suse.de>
 <Pine.LNX.4.58.0401281205250.28145@home.osdl.org> <20040128211554.0cc890fb.ak@suse.de>
 <Pine.LNX.4.58.0401281221320.28145@home.osdl.org> <20040128220921.7ba0bb78.ak@suse.de>
 <Pine.LNX.4.58.0401281340301.28145@home.osdl.org> <20040128225205.02193769.ak@suse.de>
In-Reply-To: <20040128225205.02193769.ak@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Andi Kleen <ak@suse.de>
Cc: willy@debian.org, ishii.hironobu@jp.fujitsu.com, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org



On Wed, 28 Jan 2004, Andi Kleen wrote:
> 
> I have no idea how to do such an synchronization on i386/x86-64. E.g. Opteron
> chipsets would likely support MCEs for bus aborts, but there is no way to 
> synchronize it for writes.

Doing a status read from the device should do it (just read the config 
space, for example).

But remember: I suspect there are very _very_ few people who care at that 
stage. 

		Linus
