From: Alex Williamson <alex.williamson@hp.com>
Date: Wed, 03 Sep 2003 17:33:27 +0000
Subject: Re: [patch] platform hook for timer_interrupt()
Message-Id: <marc-linux-ia64-106261126016888@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106261055215953@msgid-missing>
In-Reply-To: <marc-linux-ia64-106261055215953@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, 2003-09-03 at 10:42, Martin Hicks wrote:
> Hello,
> 
> SGI has a need to run platform specific code during the timer interrupt.
> Attached are patches for both 2.4 and 2.6 that add a hook inside the
> timer interrupt that will run platform specific code if required.
> 
> Any opinions on this?

   Can't say that I'm fond of increasing the number of runtime platform
hooks.  Is there a need for this to be changed runtime?  If not, you
could make it a real machvec so it will get compiled out for
non-generic, non-sn2 kernel targets.  A platform hook in time_init() and
an sn2 wrapper around timer_interrupt() might do the job too.

	Alex

-- 
Alex Williamson                             HP Linux & Open Source Lab

