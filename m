From: Roland McGrath <roland@redhat.com>
Date: Mon, 31 Mar 2008 19:30:09 +0000
Subject: Re: [PATCH 2/2] x86 TS_RESTORE_SIGMASK
Message-Id: <20080331193009.8524826F8E9@magilla.localdomain>
List-Id: <linux-ia64.vger.kernel.org>
References: <20080329001230.D013726FA1D@magilla.localdomain>
	<20080329001341.7F93826FA1D@magilla.localdomain>
	<alpine.LFD.1.00.0803281746480.14670@woody.linux-foundation.org>
	<20080329022408.0DD4726FA1D@magilla.localdomain>
	<20080329031413.EA38926FA1D@magilla.localdomain>
	<20080329031451.D2E1226FA1D@magilla.localdomain>
	<20080331130106.GA15198@elte.hu>
In-Reply-To: Ingo Molnar's message of  Monday, 31 March 2008 15:01:06 +0200 <20080331130106.GA15198@elte.hu>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Ingo Molnar <mingo@elte.hu>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Martin Schwidefsky <schwidefsky@de.ibm.com>, linux-s390@vger.kernel.org, tony.luck@intel.com, linux-ia64@vger.kernel.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org

> the x86 bits look nice - but i guess this all wants to go into 2.6.26 
> via -mm (or linux-next), due to its cross-arch nature?

Yes, I would not suggest this change for 2.6.25 at this late date.


Thanks,
Roland
