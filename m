From: Russell King - ARM Linux <linux@arm.linux.org.uk>
Date: Fri, 06 Feb 2009 17:22:07 +0000
Subject: Re: [linux-next][PATCH] revert headers_check fix: ia64, fpu.h
Message-Id: <20090206172207.GL13758@n2100.arm.linux.org.uk>
List-Id: <linux-ia64.vger.kernel.org>
References: <20090206145556.GH18368@elte.hu> <1233934141.3209.20.camel@localhost.localdomain> <20090206153315.GD13758@n2100.arm.linux.org.uk> <1233935328.3209.30.camel@localhost.localdomain> <20090206155512.GF13758@n2100.arm.linux.org.uk> <20090206161229.GA8256@elte.hu> <20090206162352.GI13758@n2100.arm.linux.org.uk> <20090206163314.GA11216@elte.hu> <20090206163857.GJ13758@n2100.arm.linux.org.uk> <20090206171400.GA14818@elte.hu>
In-Reply-To: <20090206171400.GA14818@elte.hu>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Ingo Molnar <mingo@elte.hu>
Cc: Jaswinder Singh Rajput <jaswinder@kernel.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Jaswinder Singh Rajput <jaswinderlinux@gmail.com>, Linus Torvalds <torvalds@linux-foundation.org>, Sam Ravnborg <sam@ravnborg.org>, Andrew Morton <akpm@linux-foundation.org>, hskinnemoen@atmel.com, cooloney@kernel.org, tony.luck@intel.com, ralf@linux-mips.org, dhowells@redhat.com, matthew@wil.cx, chris@zankel.net, LKML <linux-kernel@vger.kernel.org>, linux-next <linux-next@vger.kernel.org>, linux-ia64 <linux-ia64@vger.kernel.org>

On Fri, Feb 06, 2009 at 06:14:00PM +0100, Ingo Molnar wrote:
> I take this that you kind of agree that that removing ugly #ifdefs spread 
> out is an upside. You failed to point out any downsides - you just seem to 
> claim that you can live without the upsides. That is fine.

I'm sorry, I thought I pointed them out in my previous emails.  Clearly
you didn't read those emails in spite of replying to them.
