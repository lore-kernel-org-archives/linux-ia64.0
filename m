From: "David S. Miller" <davem@davemloft.net>
Date: Fri, 24 Dec 2004 17:02:10 +0000
Subject: Re: Prezeroing V2 [2/4]: add second parameter to clear_page() for
Message-Id: <20041224090210.4bbe11a8.davem@davemloft.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <B8E391BBE9FE384DAA4C5C003888BE6F02900FBD@scsmsx401.amr.corp.intel.com>
	<41C20E3E.3070209@yahoo.com.au>
	<Pine.LNX.4.58.0412211154100.1313@schroedinger.engr.sgi.com>
	<Pine.LNX.4.58.0412231119540.31791@schroedinger.engr.sgi.com>
	<Pine.LNX.4.58.0412231132170.31791@schroedinger.engr.sgi.com>
	<Pine.LNX.4.58.0412231133130.31791@schroedinger.engr.sgi.com>
	<20041224083337.GA1043@openzaurus.ucw.cz>
	<Pine.LNX.4.58.0412240818030.6505@schroedinger.engr.sgi.com>
	<20041224162745.GA1178@elf.ucw.cz>
In-Reply-To: <20041224162745.GA1178@elf.ucw.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Pavel Machek <pavel@ucw.cz>
Cc: clameter@sgi.com, akpm@osdl.org, linux-ia64@vger.kernel.org, torvalds@osdl.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, 24 Dec 2004 17:27:45 +0100
Pavel Machek <pavel@ucw.cz> wrote:

> I do not know what Andi said, but having clear_page clearing two
> page*s* seems wrong to me.

It's represented by a single top-level page struct regardless
of it's order, so in that sense it's indeed a single page
no matter it's order.
