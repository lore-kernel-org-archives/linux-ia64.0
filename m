From: Jesse Barnes <jbarnes@engr.sgi.com>
Date: Thu, 04 Nov 2004 17:49:53 +0000
Subject: Re: [RFC] prefer allocations from nodes w/o CPUs
Message-Id: <200411040949.53066.jbarnes@engr.sgi.com>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="Boundary-00=_BvmiBjT7uPRESDH"
List-Id: <linux-ia64.vger.kernel.org>
References: <200411040857.25664.jbarnes@engr.sgi.com>
In-Reply-To: <200411040857.25664.jbarnes@engr.sgi.com>
To: linux-ia64@vger.kernel.org

--Boundary-00=_BvmiBjT7uPRESDH
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

On Thursday, November 4, 2004 9:33 am, Jesse Barnes wrote:
> On Thursday, November 4, 2004 9:32 am, Alex Tsariounov wrote:
> > On Thu, Nov 04, 2004 at 10:11:19AM -0700, Alex Williamson wrote:
> > > On Thu, 2004-11-04 at 08:57 -0800, Jesse Barnes wrote:
> > > > Small patch for the ia64 version of topology.h to make the zonelist
> > > > building code prefer nodes w/o CPUs for allocations.  Do any
> > > > platforms aside from Altix have nodes with only memory?  If not, then
> > > > this will only affect sn2, otherwise I'm interested in hearing
> > > > feedback.
> > >
> > >    Yes, hp sx1000 systems represent interleaved memory in a separate
> > > node w/o cpus.
> >
> > So what's the ramifications of this patch?  Does this mean that
> > interleaved memory will now be preferably allocated over cell
> > local memory on sx1000 systems?
>
> Memory local to the node will come first, followed by the closest memory
> that doesn't have associated CPUs, followed by memory belonging to other
> CPUs.

Actually, I lied.  There's a bug in find_next_best_node that prevents the 
local node from coming first if the PENALTY_FOR_NODE_WITH_CPUS is set high 
enough.  Here's the fix (I'll send it to Andrew shortly).

Jesse

--Boundary-00=_BvmiBjT7uPRESDH
Content-Type: text/plain;
  charset="iso-8859-1";
  name="local-node-with-penalty-fix.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename="local-node-with-penalty-fix.patch"

===== mm/page_alloc.c 1.239 vs edited =====
--- 1.239/mm/page_alloc.c	2004-10-25 13:06:48 -07:00
+++ edited/mm/page_alloc.c	2004-11-04 09:41:23 -08:00
@@ -1213,6 +1213,12 @@
 		if (test_bit(n, used_node_mask))
 			continue;
 
+		/* Use the local node if we haven't already */
+		if (!test_bit(node, used_node_mask)) {
+			best_node = node;
+			break;
+		}
+
 		/* Use the distance array to find the distance */
 		val = node_distance(node, n);
 

--Boundary-00=_BvmiBjT7uPRESDH--
