From: Martin Hicks <mort@wildopensource.com>
Date: Wed, 03 Sep 2003 17:33:37 +0000
Subject: Re: [patch] platform hook for timer_interrupt()
Message-Id: <marc-linux-ia64-106261125916878@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106261055215953@msgid-missing>
In-Reply-To: <marc-linux-ia64-106261055215953@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org



On Wed, Sep 03, 2003 at 06:19:00PM +0100, Matthew Wilcox wrote:
> On Wed, Sep 03, 2003 at 12:42:29PM -0400, Martin Hicks wrote:
> > SGI has a need to run platform specific code during the timer interrupt.
> > Attached are patches for both 2.4 and 2.6 that add a hook inside the
> > timer interrupt that will run platform specific code if required.
> > 
> > Any opinions on this?
> 
> Why not use add_timer()?

This is code that must be run on each CPU, so the generic timer
interface doesn't help us.  I'm not certain, but some of this code may
actually only have to run on each node (not every CPU).

mh

-- 
Wild Open Source Inc.                  mort@wildopensource.com
