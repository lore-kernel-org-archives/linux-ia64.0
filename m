From: Russ Anderson <rja@efs.americas.sgi.com>
Date: Fri, 02 Jun 2006 22:18:58 +0000
Subject: Re: Montecito processor family
Message-Id: <200606022218.k52MIwjK828087@efs.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <42ADD890.1010406@free.fr>
In-Reply-To: <42ADD890.1010406@free.fr>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

dann frazier wrote:
> 
> On Wed, May 31, 2006 at 07:20:17PM -0600, Matthew Wilcox wrote:
> > We've always felt free to change these strings before.  Anyone relying
> > on them for anything more than display-to-the-user purposes is on a
> > losing streak.
> 
> Debian Installer uses it for determining the best kernel to install -
> is there a better way?  Of course, old installers aren't expected to
> work with new kernels, so the change won't hurt us as long as someone
> notices the change.

That seems like a good reason for family and model to be
numbers straight from the hardware.  Applications can key
off the numbers.  Then the text "model name" string could 
change without breaking applications.

vendor_id       : GenuineIntel
cpu family      : 15
model           : 4
model name      : Intel(R) Pentium(R) 4 CPU 2.80GHz
stepping        : 1


-- 
Russ Anderson, OS RAS/Partitioning Project Lead  
SGI - Silicon Graphics Inc          rja@sgi.com
