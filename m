From: Matthew Dobson <colpatch@us.ibm.com>
Date: Thu, 26 Feb 2004 23:09:45 +0000
Subject: Re: [Lse-tech] Re: fix zonelist ordering for NUMA
Message-Id: <1077836985.26287.175.camel@arrakis>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="=-mZKSMcqCZOo9E2fAchYP"
List-Id: <linux-ia64.vger.kernel.org>
References: <100070000.1077834062@flay>
In-Reply-To: <100070000.1077834062@flay>
To: linux-ia64@vger.kernel.org


--=-mZKSMcqCZOo9E2fAchYP
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

On Thu, 2004-02-26 at 14:21, Martin J. Bligh wrote:
> --On Wednesday, February 25, 2004 08:54:09 -0800 Jesse Barnes <jbarnes@sgi.com> wrote:
> 
> > On Wed, Feb 25, 2004 at 02:01:16PM +0900, j-nomura@ce.jp.nec.com wrote:
> >> >   1) make it arch independent
> >> >      this means having arch code populate a SLIT-like table for use by
> >> >      the generic zonelist building code
> >> 
> >> I would like to hear the comments from people on other arch.
> >> If the same ordering rule can be applicable for others, it's nice.
> > 
> > Martin, does a scheme like this sound ok with you?  Arch specific code
> > would populate a node distance table, which would be used to build each
> > pgdat->zonelist in a smarter way than we do currently.
> 
> Yeah, looks sensible to me. We probably ought to do this:
> 
> +#ifndef node_distance
> +#define node_distance(from,to) (1)
> +#endif
> 
> in the generic fallback topology headers, not in the mm/ .c files. Matt?
> 
> Also, I seem to recall those build_zonelists functions are used for both
> NUMA and UMA ... now they're getting complex enough that it's probably
> worth making a specific non-NUMA version, if only for the sanity of
> 99% of the poor souls trying to work out how a UMA machine lays it out ;-)
> 
> It looks like it won't change ordering for existing boxes with single
> layer flat NUMA topologies (round-robin), but we probably ought to check
> that carefully ;-)
> 
> M.

Yep...  Here's a quickie for i386 and the generic header.  All other
arches would look pretty similar to the asm/i386/topology.h change.

-Matt

--=-mZKSMcqCZOo9E2fAchYP
Content-Disposition: attachment; filename=node_distance.patch
Content-Type: text/x-patch; name=node_distance.patch; charset=
Content-Transfer-Encoding: 7bit

diff -Nurp --exclude-from=/home/mcd/.dontdiff linux-2.6.3-vanilla/include/asm-generic/topology.h linux-2.6.3-topo_distance/include/asm-generic/topology.h
--- linux-2.6.3-vanilla/include/asm-generic/topology.h	Tue Feb 17 19:57:15 2004
+++ linux-2.6.3-topo_distance/include/asm-generic/topology.h	Thu Feb 26 15:02:08 2004
@@ -44,6 +44,9 @@
 #ifndef pcibus_to_cpumask
 #define pcibus_to_cpumask(bus)	(cpu_online_map)
 #endif
+#ifndef node_distance
+#define node_distance(from, to)	(1)
+#endif
 
 /* Cross-node load balancing interval. */
 #ifndef NODE_BALANCE_RATE
diff -Nurp --exclude-from=/home/mcd/.dontdiff linux-2.6.3-vanilla/include/asm-i386/topology.h linux-2.6.3-topo_distance/include/asm-i386/topology.h
--- linux-2.6.3-vanilla/include/asm-i386/topology.h	Tue Feb 17 19:57:17 2004
+++ linux-2.6.3-topo_distance/include/asm-i386/topology.h	Thu Feb 26 15:00:12 2004
@@ -66,6 +66,12 @@ static inline cpumask_t pcibus_to_cpumas
 	return node_to_cpumask(mp_bus_id_to_node[bus]);
 }
 
+/* Node-to-Node distance */
+static inline int node_distance(int from, int to)
+{
+	return 1;
+}
+
 /* Cross-node load balancing interval. */
 #define NODE_BALANCE_RATE 100
 

--=-mZKSMcqCZOo9E2fAchYP--

