From: Christoph Lameter <clameter@engr.sgi.com>
Date: Sat, 07 Jan 2006 06:35:08 +0000
Subject: Re: [ANNOUNCE] numactl 0.9 released
Message-Id: <Pine.LNX.4.62.0601062230150.21223@schroedinger.engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200601032257.53039.ak@suse.de>
In-Reply-To: <200601032257.53039.ak@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Fri, 6 Jan 2006, Andi Kleen wrote:

> Did migrate_pages make it into Linus' tree yet? I don't see it there yet. 

Not yet but I would expect it for 2.6.16. There is also an open suse RFE 
for inclusion of migrate_pages into SLES10. 

> I think the name of the command is a bit unintuitive - how 
> about calling it changenodemem or movenodemem ? (better suggestions 
> welcome) 

The name is a bit unintuitive but its named the same way as the kernel 
function. It moves pages of a process so I guess the name is good enough 
unless someone comes up with a better name.

Here is a patch to fix the various issues you pointed out. Thank you:

Index: numactl-0.9/migratepages.8
=================================--- numactl-0.9.orig/migratepages.8	2006-01-06 12:18:03.000000000 -0800
+++ numactl-0.9/migratepages.8	2006-01-06 22:29:25.000000000 -0800
@@ -11,10 +11,16 @@ migratepages \- Migrate the physical loc
 pid from-nodes to-nodes
 .SH DESCRIPTION
 .B migratepages
-moves the physical localtion of a processes pages without any changes of the
+moves the physical location of a processes pages without any changes of the
 virtual address space of the process. This is usually done to optimize
 the performance of a process by moving the pages near to the processor
 executing a process.
+
+If multiple nodes are specified for from-nodes or to-nodes then
+an attempt is made to preserve the relative location of
+each page in each nodeset. F.e. if we move from nodes 2-5 to
+7,9,12-13 then the preferred mode of transfer is to move pages from
+2->7, 3->9, 4->12 and 5->13. 
 .TP
 Valid node specifiers
 .TS
@@ -61,3 +67,6 @@ migratepages is under the GNU General Pu
 .I ftok(3)
 ,
 .I shmat(2)
+,
+.I taskset(1)
+
Index: numactl-0.9/migratepages.c
=================================--- numactl-0.9.orig/migratepages.c	2006-01-06 22:29:44.000000000 -0800
+++ numactl-0.9/migratepages.c	2006-01-06 22:29:47.000000000 -0800
@@ -81,7 +81,7 @@ int main(int argc, char *argv[])
 	checknuma();
 
 	pid = strtoul(argv[1], &end, 0);
-	if (*end)
+	if (*end || end = argv[1])
 		usage();
 
 	fromnodes = nodemask(argv[2]);
