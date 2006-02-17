From: Andi Kleen <ak@suse.de>
Date: Fri, 17 Feb 2006 16:16:33 +0000
Subject: Re: [PATCH: 001/012] Memory hotplug for new nodes v.2. (pgdat allocation)
Message-Id: <200602171716.34297.ak@suse.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060217210749.406A.Y-GOTO@jp.fujitsu.com> <1140190792.21383.64.camel@localhost.localdomain>
In-Reply-To: <1140190792.21383.64.camel@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Dave Hansen <haveblue@us.ibm.com>
Cc: Yasunori Goto <y-goto@jp.fujitsu.com>, Andrew Morton <akpm@osdl.org>, "Luck, Tony" <tony.luck@intel.com>, "Tolentino, Matthew E" <matthew.e.tolentino@intel.com>, Joel Schopp <jschopp@austin.ibm.com>, linux-ia64@vger.kernel.org, Linux Kernel ML <linux-kernel@vger.kernel.org>, x86-64 Discuss <discuss@x86-64.org>

On Friday 17 February 2006 16:39, Dave Hansen wrote:

> I'm a teensy bit concerned that this doesn't share enough code with the
> boot-time initialization.  For instance, the kthread_create() seems to
> be a pretty darn generic piece.  I'd feel a lot more at ease if this
> patch did something with _existing_ code instead of just adding.

Agreed. Having significantly different code paths for hot add and
for normal initialization isn't a good idea. It will just lead to 
long term code drift and problems.

So i would suggest to generalize the standard functions enough
to make them callable from a hotplug layer.

-Andi
