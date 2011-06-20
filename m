From: Ingo Molnar <mingo@elte.hu>
Date: Mon, 20 Jun 2011 16:40:45 +0000
Subject: Re: [PATCH 00/10] Enhance /dev/mem to allow read/write of arbitrary
Message-Id: <20110620164045.GB10815@elte.hu>
List-Id: <linux-ia64.vger.kernel.org>
References: <201106171038.25988.ptesarik@suse.cz>
	<20110617093032.GA19235@elte.hu> <4DFE7FF9.9070406@gmail.com>
	<4DFE89E0.5020509@zytor.com> <20110620074124.GB24716@elte.hu>
	<4DFF6E58.8090306@zytor.com>
In-Reply-To: <4DFF6E58.8090306@zytor.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-arm-kernel@lists.infradead.org


* H. Peter Anvin <hpa@zytor.com> wrote:

> On 06/20/2011 12:41 AM, Ingo Molnar wrote:
> > 
> > * H. Peter Anvin <hpa@zytor.com> wrote:
> > 
> >> There are some test drivers which really want /dev/mem to work.
> > 
> > Test drivers and test hardware with zero enumeration can use below 4G 
> > addresses just fine.
> >
> > Also, debugging is not an issue and some non-default kernel or boot 
> > option can enable any sort of device i guess, so my main worry isnt 
> > really security but that we should stand in the way of the apparent 
> > practice of *shipping* user-space drivers that use /dev/mem ...
> > 
> 
> We should either fix /dev/mem to work according to its 
> specification or rip it out.  The issue with test drivers is not 
> spurious... I ran into this one myself a few weeks ago while trying 
> to do a memory test (by limiting the amount of memory available to 
> the kernel).  This is something that is typically done on factory 
> floors, and it would be nice to be able to get those environments 
> over to using Linux.

There is no reason why they couldnt use a .config option or a boot 
option to get their weird stuff going, which weird stuff also happens 
to be useful.

What i'm somewhat against is having this enabled by default for weird 
stuff that also happens to be harmful - and the fact that it never 
worked over 4G physical gives us the perfect opportunity to do just 
that.

Thanks,

	Ingo
