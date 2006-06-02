From: Alex Williamson <alex.williamson@hp.com>
Date: Fri, 02 Jun 2006 19:08:44 +0000
Subject: [RFC 0/2] Xen/ia64 kernel changes
Message-Id: <1149275324.5999.82.camel@lappy>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi all,

   I'd like to get some feedback on our current set of changes to the
Linux/ia64 kernel to support privileged and un-privileged guests running
on the Xen/ia64 hypervisor.  These are not yet meant for inclusion in
the Linux/ia64 tree, but rather for review and suggestions as well as
ensuring that we're not heading down an unacceptable path for an
eventual merge.

   If you haven't been paying attention to the status of Xen/ia64, we've
made a lot of huge leaps in functionality over the last few months.
We've completed integration of the domain0 virtual-physical memory
model, which allows us to better leverage the virtual device drivers and
infrastructure of Xen.  Perhaps most importantly for users, this enables
support for the Xen virtual network driver, finally giving us a working
network in guest domains!  SMP support has also been added for Xen/ia64
as well as paravirtualized guests (VTI guest SMP support coming soon).
FPSWA support has been added, cleaning up our last remaining LTP test
failures.  There are also numerous other fixes and additions as well as
a strong effort to cleanup the code base.  We're quickly approaching
functional parity with Xen/x86.

   I've split the patches up into two big chunks, changes to existing
code and new code.  Obviously we'll need finer granularity patch sets
when we think about merging these.  The first (and smaller) patch is the
changes to existing code.  These changes probably need the more
stringent review.  All changes are relative to upstream 2.6.17-rc5.
This is a newer code base than we're using in the current xen-ia64-devel
tree, so this is for reference only and not meant to necessarily work.
Please see:

http://xenbits.xensource.com/ext/xen-ia64-unstable.hg

for the current working version.  Xen/ia64 developers may also notice
that I've removed chunks of code to support the old non-vp memory model
in order to make the patches a bit smaller.  Please be sure to include
the xen-ia64-devel mailing list <xen-ia64-devel@lists.xensource.com>
with any feedback.  Thanks,

	Alex

-- 
Alex Williamson                             HP Open Source & Linux Org.

