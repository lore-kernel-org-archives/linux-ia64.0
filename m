From: "David S. Miller" <davem@davemloft.net>
Date: Sun, 27 Mar 2005 18:23:13 +0000
Subject: Re: [PATCH] add a clear_pages function to clear pages of higher
Message-Id: <20050327102313.04498cdc.davem@davemloft.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.58.0503101229420.13911@schroedinger.engr.sgi.com>
	<200503111008.12134.vda@port.imtp.ilyichevsk.odessa.ua>
	<Pine.LNX.4.58.0503161720570.1787@schroedinger.engr.sgi.com>
	<200503181154.37414.vda@port.imtp.ilyichevsk.odessa.ua>
	<Pine.LNX.4.58.0503180652350.15022@schroedinger.engr.sgi.com>
	<20050318192808.GB38053@muc.de>
	<16963.2075.713737.485070@napali.hpl.hp.com>
	<20050327171220.GA18506@muc.de>
In-Reply-To: <20050327171220.GA18506@muc.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Andi Kleen <ak@muc.de>
Cc: davidm@hpl.hp.com, clameter@sgi.com, vda@port.imtp.ilyichevsk.odessa.ua, haveblue@us.ibm.com, akpm@osdl.org, linux-kernel@vger.kernel.org, mel@csn.ul.ie, linux-ia64@vger.kernel.org, Jens.Maurer@gmx.net

On 27 Mar 2005 19:12:20 +0200
Andi Kleen <ak@muc.de> wrote:

> With non temporal stores
> you guarantee at least one hard cache miss directly after
> the return to user space.

This is true if the cacheline were not present already at
the time of the non-temporal store.

I know what you're trying to say, I'm just clarifying.

The real question is if a large enough ratio of those
cachelines in the page get similarly accessed.  I happen
to think the answer to that for any real example is yes.
Yet, I have no way to prove this.

It would be cool to do some hacks under Xen or user-mode
Linux to get some real statistics about this.  Actually,
this could be done also with hacks to valgrind or other
similar tools.  QEMU could also be used.
