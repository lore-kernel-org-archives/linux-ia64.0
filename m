From: Linus Torvalds <torvalds@osdl.org>
Date: Wed, 28 Jan 2004 20:06:12 +0000
Subject: Re: [RFC/PATCH, 2/4] readX_check() performance evaluation
Message-Id: <Pine.LNX.4.58.0401281205250.28145@home.osdl.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <00a301c3e541$c13a6350$2987110a@lsd.css.fujitsu.com>
 <Pine.LNX.4.58.0401271847440.10794@home.osdl.org>
 <20040128182003.GL11844@parcelfarce.linux.theplanet.co.uk>
 <Pine.LNX.4.58.0401281129570.28145@home.osdl.org> <20040128204049.627e6312.ak@suse.de>
In-Reply-To: <20040128204049.627e6312.ak@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Andi Kleen <ak@suse.de>
Cc: willy@debian.org, ishii.hironobu@jp.fujitsu.com, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org



On Wed, 28 Jan 2004, Andi Kleen wrote:
>
> On Wed, 28 Jan 2004 11:33:33 -0800 (PST)
> Linus Torvalds <torvalds@osdl.org> wrote:
> 
> > For example, if checking for an error involves actually reading a value 
> > from a bridge register, then that implies some _serious_ amount of 
> > serialization and external CPU stuff.
> 
> Which is _extremly_ hard to do from an MCE handler ...

So don't do it in the MCE handler.

Just set a flag aka "may need checking", and let the check be done by the 
actual "read_pcix_error()" code.

		Linus
