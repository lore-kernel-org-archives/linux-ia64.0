From: Alex Williamson <alex_williamson@hp.com>
Date: Mon, 23 Jun 2003 15:27:12 +0000
Subject: Re: i2000 firmware 117c
Message-Id: <marc-linux-ia64-105638366204676@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105638142401915@msgid-missing>
In-Reply-To: <marc-linux-ia64-105638142401915@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Richard,

   See this post on debian-ia64:

http://lists.debian.org/debian-ia64/2003/debian-ia64-200306/msg00008.html

Ben Collins has made an ISO image available with firmware
117c.  I put in a request to get 117c back up on the
driver download page at hp.com.  It sounded like it was
in progress, but I'll check on it to see it gets done.
Thanks,

	Alex

Richard C Bilson wrote:
> 
> Back in May, Alex Williamson from HP observed:
> 
> > In short, if you're not up to at least firmware rev 117c on your i2000,
> > you need to upgraded.  The CPE polling between 2.4 & 2.5 should be pretty
> > much identical.
> 
> I have an i2000 here that is still running rev 103, and I'd like to
> upgrade it.  Problem is, it has a C1 processor, and the current
> firmware release (130) requires a C2.  Is there any way I can get
> access to the 117c firmware release?
> 
> The good news is that 2.5.72 seems to run fine on the box anyway (with
> CONFIG_MCA disabled, mind you); special thanks to Peter Chubb for
> fixing the keyboard problem.
> 
> --
> Richard C. Bilson, Research Assistant   | School of Computer Science
> rcbilson@plg.uwaterloo.ca               | University of Waterloo
> http://plg.uwaterloo.ca/~rcbilson       | 200 University Avenue West
> Office: DC 3548F Ph: (519)888-4567x4822 | Waterloo, Ontario, CANADA N2L 3G1
> -
> To unsubscribe from this list: send the line "unsubscribe linux-ia64" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

-- 
Alex Williamson                             HP Linux & Open Source Lab
