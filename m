From: Alex Williamson <alex.williamson@hp.com>
Date: Sat, 11 Sep 2004 21:26:28 +0000
Subject: Re: [PATCH] 2.6.9-rc1 Ia64 build broken due to HPET
Message-Id: <1094937988.4254.1.camel@mythbox>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040910041200.GN5668@cse.unsw.EDU.AU>
In-Reply-To: <20040910041200.GN5668@cse.unsw.EDU.AU>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Sat, 2004-09-11 at 21:28 +0200, Gerald Pfeifer wrote:
> On Sat, 11 Sep 2004, Matthew Wilcox wrote:
> > There is no hpet device in currently shipping zx1 boxes.  I'm not sure
> > there's one in currently shipping sx1000 boxes either.
> 
> I'm believe Eigers (rx7620) and Olympias (rx8620) come with HPET,
> at least they claim to. ;-)
> 
>   ACPI: HPET (v001     HP   rx8620 0x00000000   HP 0x00000000) @ ....
> 

   Yes, all the sx1000 based boxes should have one.  I'll try to get a
newer glibc on one and run the test program again, unless someone beats
be to it.

	Alex

