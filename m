From: Andi Kleen <ak@suse.de>
Date: Wed, 28 Jan 2004 22:39:48 +0000
Subject: Re: [RFC/PATCH, 2/4] readX_check() performance evaluation
Message-Id: <20040128233948.26a36ff7.ak@suse.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <00a301c3e541$c13a6350$2987110a@lsd.css.fujitsu.com>
	<Pine.LNX.4.58.0401271847440.10794@home.osdl.org>
	<20040128182003.GL11844@parcelfarce.linux.theplanet.co.uk>
	<Pine.LNX.4.58.0401281129570.28145@home.osdl.org>
	<20040128204049.627e6312.ak@suse.de>
	<Pine.LNX.4.58.0401281205250.28145@home.osdl.org>
	<20040128211554.0cc890fb.ak@suse.de>
	<Pine.LNX.4.58.0401281221320.28145@home.osdl.org>
	<20040128220921.7ba0bb78.ak@suse.de>
	<Pine.LNX.4.58.0401281340301.28145@home.osdl.org>
	<20040128225205.02193769.ak@suse.de>
	<Pine.LNX.4.58.0401281420430.28145@home.osdl.org>
In-Reply-To: <Pine.LNX.4.58.0401281420430.28145@home.osdl.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Linus Torvalds <torvalds@osdl.org>
Cc: willy@debian.org, ishii.hironobu@jp.fujitsu.com, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org

On Wed, 28 Jan 2004 14:21:40 -0800 (PST)
Linus Torvalds <torvalds@osdl.org> wrote:

> 
> 
> On Wed, 28 Jan 2004, Andi Kleen wrote:
> > 
> > I have no idea how to do such an synchronization on i386/x86-64. E.g. Opteron
> > chipsets would likely support MCEs for bus aborts, but there is no way to 
> > synchronize it for writes.
> 
> Doing a status read from the device should do it (just read the config 
> space, for example).

The device is just not known. iirc you only get a bit in the bridge, which
leaves a wide choice. Ok, I guess you could read all config spaces in this
case

(I don't remember the ordering rules well enough - maybe one single config
space read is enough for all devices behind the bridge) 

> But remember: I suspect there are very _very_ few people who care at that 
> stage. 

Driver writers caring would be a good start.

I definitely agree that it shouldn't be enabled on anything near a production kernel.

-Andi
