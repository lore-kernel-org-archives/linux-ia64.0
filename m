From: Matthew Wilcox <willy@debian.org>
Date: Wed, 03 Sep 2003 17:19:00 +0000
Subject: Re: [patch] platform hook for timer_interrupt()
Message-Id: <marc-linux-ia64-106261055215953@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, Sep 03, 2003 at 12:42:29PM -0400, Martin Hicks wrote:
> SGI has a need to run platform specific code during the timer interrupt.
> Attached are patches for both 2.4 and 2.6 that add a hook inside the
> timer interrupt that will run platform specific code if required.
> 
> Any opinions on this?

Why not use add_timer()?

-- 
"It's not Hollywood.  War is real, war is primarily not about defeat or
victory, it is about death.  I've seen thousands and thousands of dead bodies.
Do you think I want to have an academic debate on this subject?" -- Robert Fisk
