From: Linus Torvalds <torvalds@osdl.org>
Date: Wed, 28 Jan 2004 20:30:48 +0000
Subject: Re: [RFC/PATCH, 2/4] readX_check() performance evaluation
Message-Id: <Pine.LNX.4.58.0401281229150.28145@home.osdl.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <00a301c3e541$c13a6350$2987110a@lsd.css.fujitsu.com>
 <Pine.LNX.4.58.0401271847440.10794@home.osdl.org>
 <20040128182003.GL11844@parcelfarce.linux.theplanet.co.uk>
 <Pine.LNX.4.58.0401281129570.28145@home.osdl.org> <20040128204049.627e6312.ak@suse.de>
 <Pine.LNX.4.58.0401281205250.28145@home.osdl.org> <20040128211554.0cc890fb.ak@suse.de>
 <Pine.LNX.4.58.0401281221320.28145@home.osdl.org>
In-Reply-To: <Pine.LNX.4.58.0401281221320.28145@home.osdl.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Andi Kleen <ak@suse.de>
Cc: willy@debian.org, ishii.hironobu@jp.fujitsu.com, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org



On Wed, 28 Jan 2004, Linus Torvalds wrote:
> 
> If the real error is on the bridge somewhere but you don't even know which
> CPU did the access (and just "somebody" gets an MCE), just set a global
> flag, and have "read_pcix_error()" check the bridge (since it doesn't need
> to look anything up - it already knows the device).
> 
> And in that case then you need to take the proper locks (per-bridge, or
> global, depending on just how much you care) in "clear_pcix_error()" and
> release them in "read_pcix_error()".

Note, in case this wasn't clear already: in this case, the "MCE flag" is 
just a lazy flag saying "you need to check more deeply". It wouldn't cause 
false positives, simply because the _real_ check ends up being 
"read_pcix_error()" actually reading the error status from the bridge or 
the device.

It's just that 99% of the time, you don't want to do even that.

		Linus
