From: Matthew Wilcox <willy@debian.org>
Date: Wed, 03 Sep 2003 18:49:18 +0000
Subject: Re: [patch] platform hook for timer_interrupt()
Message-Id: <marc-linux-ia64-106261593423004@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106261055215953@msgid-missing>
In-Reply-To: <marc-linux-ia64-106261055215953@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, Sep 03, 2003 at 01:33:37PM -0400, Martin Hicks wrote:
> > Why not use add_timer()?
> 
> This is code that must be run on each CPU, so the generic timer
> interface doesn't help us.  I'm not certain, but some of this code may
> actually only have to run on each node (not every CPU).

How about smp_call_function() in a regular timer then?

-- 
"It's not Hollywood.  War is real, war is primarily not about defeat or
victory, it is about death.  I've seen thousands and thousands of dead bodies.
Do you think I want to have an academic debate on this subject?" -- Robert Fisk
