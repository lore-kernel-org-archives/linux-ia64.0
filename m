From: Jim Wilson <wilson@specifixinc.com>
Date: Thu, 27 Nov 2003 06:52:50 +0000
Subject: Re: Unwind bug on out of line code called from leaf functions
Message-Id: <marc-linux-ia64-106997302626988@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106989195923088@msgid-missing>
In-Reply-To: <marc-linux-ia64-106989195923088@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, 2003-11-26 at 20:28, David Mosberger wrote:
> gcc-3.3.2 also can handle ar.pfs clobbers, so we may just want to
> update the kernel code to be a bit more premissive and not insist on
> >= gcc-3.4.  I'm not exactly sure though when this got fixed, so
> somebody would have to look into that first.

The patch is in gcc-3.3.0.  See Richard Henderson's 2003-04-26 ia64
change in gcc.  However, that patch resulted in an ICE in some other
cases, and unnecessary saves/restores of ar.pfs, see gcc PR 10681.  The
patch for that is in gcc-3.3.1.  See Richard Henderson's 2003-06-26
change in gcc.

It would be reasonable to just check for >= gcc-3.3 for use of this
feature.  I wouldn't recommend using gcc-3.3.0 though.
-- 
Jim Wilson, GNU Tools Support, http://www.SpecifixInc.com

