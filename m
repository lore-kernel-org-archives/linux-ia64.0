From: "Luck, Tony" <tony.luck@intel.com>
Date: Thu, 06 Nov 2003 19:09:37 +0000
Subject: RE: [RFC] Better MCA recovery on IPF
Message-Id: <marc-linux-ia64-106814589713942@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106724227826901@msgid-missing>
In-Reply-To: <marc-linux-ia64-106724227826901@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> By the way, what do you mean by "less scope to avoid the 
> MCA"? this statement seems to imply that some existing implementations do it 
> (avoid generating and MCA when a ld.s accesses poisoned data) under some 
> circumstances. Can you elaborate?

I was just being vague.  In the case of "ld.s" the data is
targetted at a register ... and we don't have a way to indicate
that the contents of a register are poisoned (NaT would at least
stop someone consuming the poisoned data, but they wouldn't know
why) ... so an MCA is inevitable.  In the "lfetch" case we only
requested that the data be pulled into cache, which can keep track
of whether it is poisoned or not ... so it is architecturally possible
to avoid the MCA.

I don't have the details to hand on how existing implementations
actually handle this.

-Tony
