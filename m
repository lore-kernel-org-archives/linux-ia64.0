From: Peter Chubb <peterc@gelato.unsw.edu.au>
Date: Tue, 28 Aug 2007 23:01:57 +0000
Subject: Re: wmb vs mmiowb
Message-Id: <87ps17jmai.wl%peterc@chubb.wattle.id.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <20070822045714.GD26374@wotan.suse.de>
	<alpine.LFD.0.999.0708221049560.30176@woody.linux-foundation.org>
	<1187854035.5972.4.camel@localhost.localdomain>
	<200708230956.17049.jesse.barnes@intel.com>
	<20070828155714.Q5403@pkunk.americas.sgi.com>
In-Reply-To: <20070828155714.Q5403@pkunk.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Brent Casavant <bcasavan@sgi.com>
Cc: Nick Piggin <npiggin@suse.de>, linux-ia64@vger.kernel.org, linuxppc-dev@ozlabs.org, Jesse Barnes <jesse.barnes@intel.com>, Linus Torvalds <torvalds@linux-foundation.org>

>>>>> "Brent" = Brent Casavant <bcasavan@sgi.com> writes:

Brent> That reminds me.  Are the people who are working on the
Brent> user-level driver effort including a capability similar to
Brent> mmiowb()?  If we had that capability we could eventually do
Brent> away with the change mentioned above.  But that would come
Brent> after all user-level drivers were coded to include the
Brent> mmiowb()-like calls, and existing drivers which provide mmap()
Brent> capability directly to hardware go away.

Not at present, because the platforms *I'm* mostly targetting at the
moment don't need it.  

--
Dr Peter Chubb  http://www.gelato.unsw.edu.au  peterc AT gelato.unsw.edu.au
http://www.ertos.nicta.com.au           ERTOS within National ICT Australia
