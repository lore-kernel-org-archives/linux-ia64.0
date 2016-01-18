From: Ganapatrao Kulkarni <gkulkarni@caviumnetworks.com>
Date: Mon, 18 Jan 2016 16:48:01 +0000
Subject: [PATCH v9 2/6] Documentation, dt, arm64/arm: dt bindings for numa.
Message-Id: <1453134965-6125-3-git-send-email-gkulkarni@caviumnetworks.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1453134965-6125-1-git-send-email-gkulkarni@caviumnetworks.com>
In-Reply-To: <1453134965-6125-1-git-send-email-gkulkarni-M3mlKVOIwJVv6pq1l3V1OdBPR1lH4CV8@public.gmane.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-pci-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-ia64-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-metag-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linuxppc-dev-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org, linux-s390-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-sh-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-arch-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Will.Deacon-5wv7dgnIgG8@public.gmane.org, catalin.marinas-5wv7dgnIgG8@public.gmane.org, grant.likely-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org, leif.lindholm-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org, rfranz-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org, ard.biesheuvel-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org, msalter-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, steve.capper-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org, hanjun.guo-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org, al.stone-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org, arnd-r2nGTMty4D4@public.gmane.org, pawel.moll-5wv7dgnIgG8@public.gmane.org, mark.rutland-5wv7dgnIgG8@public.gmane.org, ijc+devicetree-KcIKpvwj1kUDXYZnReoRVg@public.gmane.org, galak-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org, rjw-LthD3rsA81gm4RdzfppkhA@public.gmane.org, lenb-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, marc.zyngier-5wv7dgnIgG8@public.gmane.org, lorenzo.pieralisi-5wv7dgnIgG8@public.gmane.org, bhelgaas-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, tony.luck-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, fenghua.yu-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, james.hog
Cc: gpkulkarni-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org

DT bindings for numa mapping of memory, cores and IOs.

Reviewed-by: Robert Richter <rrichter@cavium.com>
Signed-off-by: Ganapatrao Kulkarni <gkulkarni@caviumnetworks.com>
---
 Documentation/devicetree/bindings/arm/numa.txt | 272 +++++++++++++++++++++++++
 1 file changed, 272 insertions(+)
 create mode 100644 Documentation/devicetree/bindings/arm/numa.txt

diff --git a/Documentation/devicetree/bindings/arm/numa.txt b/Documentation/devicetree/bindings/arm/numa.txt
new file mode 100644
index 0000000..734e5b4
--- /dev/null
+++ b/Documentation/devicetree/bindings/arm/numa.txt
@@ -0,0 +1,272 @@
+=======================================
+NUMA binding description.
+=======================================
+
+=======================================
+1 - Introduction
+=======================================
+
+Systems employing a Non Uniform Memory Access (NUMA) architecture contain
+collections of hardware resources including processors, memory, and I/O buses,
+that comprise what is commonly known as a NUMA node.
+Processor accesses to memory within the local NUMA node is generally faster
+than processor accesses to memory outside of the local NUMA node.
+DT defines interfaces that allow the platform to convey NUMA node
+topology information to OS.
+
+=======================================
+2 - numa-node-id
+=======================================
+
+For the purpose of identification, each NUMA node is associated with a unique
+token known as a node id. For the purpose of this binding
+a node id is a 32-bit integer.
+
+A device node is associated with a NUMA node by the presence of a
+numa-node-id property which contains the node id of the device.
+
+Example:
+	/* numa node 0 */
+	numa-node-id = <0>;
+
+	/* numa node 1 */
+	numa-node-id = <1>;
+
+=======================================
+3 - distance-map
+=======================================
+
+The device tree node distance-map describes the relative
+distance (memory latency) between all numa nodes.
+
+- compatible : Should at least contain "numa-distance-map-v1".
+
+- distance-matrix
+  This property defines a matrix to describe the relative distances
+  between all numa nodes.
+  It is represented as a list of node pairs and their relative distance.
+
+  Note:
+	1. Each entry represents distance from first node to second node.
+	The distances are equal in either direction.
+	2. The distance from a node to self (local distance) is represented
+	with value 10 and all internode distance should be represented with
+	a value greater than 10.
+	3. distance-matrix should have entries in lexicographical ascending
+	order of nodes.
+	4. There must be only one device node distance-map which must reside in the root node.
+
+Example:
+	4 nodes connected in mesh/ring topology as below,
+
+		0_______20______1
+		|               |
+		|               |
+		20             20
+		|               |
+		|               |
+		|_______________|
+		3       20      2
+
+	if relative distance for each hop is 20,
+	then internode distance would be,
+	      0 -> 1 = 20
+	      1 -> 2 = 20
+	      2 -> 3 = 20
+	      3 -> 0 = 20
+	      0 -> 2 = 40
+	      1 -> 3 = 40
+
+     and dt presentation for this distance matrix is,
+
+		distance-map {
+			 compatible = "numa-distance-map-v1";
+			 distance-matrix = <0 0  10>,
+					   <0 1  20>,
+					   <0 2  40>,
+					   <0 3  20>,
+					   <1 0  20>,
+					   <1 1  10>,
+					   <1 2  20>,
+					   <1 3  40>,
+					   <2 0  40>,
+					   <2 1  20>,
+					   <2 2  10>,
+					   <2 3  20>,
+					   <3 0  20>,
+					   <3 1  40>,
+					   <3 2  20>,
+					   <3 3  10>;
+		};
+
+=======================================
+4 - Example dts
+=======================================
+
+2 sockets system consists of 2 boards connected through ccn bus and
+each board having one socket/soc of 8 cpus, memory and pci bus.
+
+	memory@00c00000 {
+		device_type = "memory";
+		reg = <0x0 0x00c00000 0x0 0x80000000>;
+		/* node 0 */
+		numa-node-id = <0>;
+	};
+
+	memory@10000000000 {
+		device_type = "memory";
+		reg = <0x100 0x00000000 0x0 0x80000000>;
+		/* node 1 */
+		numa-node-id = <1>;
+	};
+
+	cpus {
+		#address-cells = <2>;
+		#size-cells = <0>;
+
+		cpu@000 {
+			device_type = "cpu";
+			compatible =  "arm,armv8";
+			reg = <0x0 0x000>;
+			enable-method = "psci";
+			/* node 0 */
+			numa-node-id = <0>;
+		};
+		cpu@001 {
+			device_type = "cpu";
+			compatible =  "arm,armv8";
+			reg = <0x0 0x001>;
+			enable-method = "psci";
+			numa-node-id = <0>;
+		};
+		cpu@002 {
+			device_type = "cpu";
+			compatible =  "arm,armv8";
+			reg = <0x0 0x002>;
+			enable-method = "psci";
+			numa-node-id = <0>;
+		};
+		cpu@003 {
+			device_type = "cpu";
+			compatible =  "arm,armv8";
+			reg = <0x0 0x003>;
+			enable-method = "psci";
+			numa-node-id = <0>;
+		};
+		cpu@004 {
+			device_type = "cpu";
+			compatible =  "arm,armv8";
+			reg = <0x0 0x004>;
+			enable-method = "psci";
+			numa-node-id = <0>;
+		};
+		cpu@005 {
+			device_type = "cpu";
+			compatible =  "arm,armv8";
+			reg = <0x0 0x005>;
+			enable-method = "psci";
+			numa-node-id = <0>;
+		};
+		cpu@006 {
+			device_type = "cpu";
+			compatible =  "arm,armv8";
+			reg = <0x0 0x006>;
+			enable-method = "psci";
+			numa-node-id = <0>;
+		};
+		cpu@007 {
+			device_type = "cpu";
+			compatible =  "arm,armv8";
+			reg = <0x0 0x007>;
+			enable-method = "psci";
+			numa-node-id = <0>;
+		};
+		cpu@008 {
+			device_type = "cpu";
+			compatible =  "arm,armv8";
+			reg = <0x0 0x008>;
+			enable-method = "psci";
+			/* node 1 */
+			numa-node-id = <1>;
+		};
+		cpu@009 {
+			device_type = "cpu";
+			compatible =  "arm,armv8";
+			reg = <0x0 0x009>;
+			enable-method = "psci";
+			numa-node-id = <1>;
+		};
+		cpu@00a {
+			device_type = "cpu";
+			compatible =  "arm,armv8";
+			reg = <0x0 0x00a>;
+			enable-method = "psci";
+			numa-node-id = <1>;
+		};
+		cpu@00b {
+			device_type = "cpu";
+			compatible =  "arm,armv8";
+			reg = <0x0 0x00b>;
+			enable-method = "psci";
+			numa-node-id = <1>;
+		};
+		cpu@00c {
+			device_type = "cpu";
+			compatible =  "arm,armv8";
+			reg = <0x0 0x00c>;
+			enable-method = "psci";
+			numa-node-id = <1>;
+		};
+		cpu@00d {
+			device_type = "cpu";
+			compatible =  "arm,armv8";
+			reg = <0x0 0x00d>;
+			enable-method = "psci";
+			numa-node-id = <1>;
+		};
+		cpu@00e {
+			device_type = "cpu";
+			compatible =  "arm,armv8";
+			reg = <0x0 0x00e>;
+			enable-method = "psci";
+			numa-node-id = <1>;
+		};
+		cpu@00f {
+			device_type = "cpu";
+			compatible =  "arm,armv8";
+			reg = <0x0 0x00f>;
+			enable-method = "psci";
+			numa-node-id = <1>;
+		};
+	};
+
+	pcie0: pcie0@0x8480,00000000 {
+		compatible = "arm,armv8";
+		device_type = "pci";
+		bus-range = <0 255>;
+		#size-cells = <2>;
+		#address-cells = <3>;
+		reg = <0x8480 0x00000000 0 0x10000000>;  /* Configuration space */
+		ranges = <0x03000000 0x8010 0x00000000 0x8010 0x00000000 0x70 0x00000000>;
+		/* node 0 */
+		numa-node-id = <0>;
+        };
+
+	pcie1: pcie1@0x9480,00000000 {
+		compatible = "arm,armv8";
+		device_type = "pci";
+		bus-range = <0 255>;
+		#size-cells = <2>;
+		#address-cells = <3>;
+		reg = <0x9480 0x00000000 0 0x10000000>;  /* Configuration space */
+		ranges = <0x03000000 0x9010 0x00000000 0x9010 0x00000000 0x70 0x00000000>;
+		/* node 1 */
+		numa-node-id = <1>;
+        };
+
+	distance-map {
+		compatible = "numa-distance-map-v1";
+		distance-matrix = <0 0 10>,
+				  <0 1 20>,
+				  <1 1 10>;
+	};
-- 
1.8.1.4

