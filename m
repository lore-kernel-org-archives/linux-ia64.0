From: Richard C Bilson <rcbilson@plg2.math.uwaterloo.ca>
Date: Mon, 23 Jun 2003 15:16:57 +0000
Subject: i2000 firmware 117c
Message-Id: <marc-linux-ia64-105638142401915@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Back in May, Alex Williamson from HP observed:

> In short, if you're not up to at least firmware rev 117c on your i2000,
> you need to upgraded.  The CPE polling between 2.4 & 2.5 should be pretty
> much identical.

I have an i2000 here that is still running rev 103, and I'd like to
upgrade it.  Problem is, it has a C1 processor, and the current
firmware release (130) requires a C2.  Is there any way I can get
access to the 117c firmware release?

The good news is that 2.5.72 seems to run fine on the box anyway (with
CONFIG_MCA disabled, mind you); special thanks to Peter Chubb for
fixing the keyboard problem.

-- 
Richard C. Bilson, Research Assistant   | School of Computer Science
rcbilson@plg.uwaterloo.ca               | University of Waterloo
http://plg.uwaterloo.ca/~rcbilson       | 200 University Avenue West
Office: DC 3548F Ph: (519)888-4567x4822 | Waterloo, Ontario, CANADA N2L 3G1
