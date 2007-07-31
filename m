From: Jes Sorensen <jes@sgi.com>
Date: Tue, 31 Jul 2007 14:34:41 +0000
Subject: Re: panic from vector domain patch (was RE: Linus' tree broken?)
Message-Id: <46AF4881.504@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1185239265.19353.6.camel@phobos>
In-Reply-To: <1185239265.19353.6.camel@phobos>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Doug Chapman wrote:
> FYI, booting for me just fine on a RHEL5 installed base.  What distro
> were you booting on?

Ok, I figured out which patch caused it, now to figure out whats wrong
and how to fix it :(

Jes


jes@eye:~/src/kernel/linus/lguest/linux-2.6-lguest> git bisect 
bad0aa366f351d044703e25c8425e508170e80d83b1 is first bad commit
commit 0aa366f351d044703e25c8425e508170e80d83b1
Author: Tony Luck <tony.luck@intel.com>
Date:   Fri Jul 20 11:22:30 2007 -0700

     [IA64] Convert to generic timekeeping/clocksource

     This is a merge of Peter Keilty's initial patch (which was
     revived by Bob Picco) for this with Hidetoshi Seto's fixes
     and scaling improvements.

     Acked-by: Bob Picco <bob.picco@hp.com>
     Signed-off-by: Tony Luck <tony.luck@intel.com>

