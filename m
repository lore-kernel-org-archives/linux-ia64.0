From: Robert Picco <Robert.Picco@hp.com>
Date: Wed, 18 Feb 2004 15:33:29 +0000
Subject: Re: PXM/Nid/SLIT patch
Message-Id: <403385C9.5060400@hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <40321CF7.5020301@hp.com>
In-Reply-To: <40321CF7.5020301@hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Jesse Barnes wrote:

>On Tue, Feb 17, 2004 at 08:53:59AM -0500, Robert Picco wrote:
>  
>
>>+++ linux-2.6.2/arch/ia64/kernel/acpi.c	2004-02-17 
>>06:10:20.000000000 -0500
>>@@ -338,11 +338,16 @@
>>#undef SLIT_DEBUG
>>
>>#define PXM_FLAG_LEN ((MAX_PXM_DOMAINS + 1)/32)
>>+#define	PXM_MAGIC	(255)
>>    
>>
>
>Is this a reserved value in the ACPI SLIT spec?  I don't have it handy,
>so I can't check that this would be a magic Linux-only value.
>
>Also, I can't be sure (since my .muttrc is known to be weird), but I
>think the patch got wrapped somehow, and doesn't seem to conform
>entirely to Documentation/CodingStyle...  Haven't really looked at it
>other than that yet.
>
>Jesse
>
>  
>
This PXM value (255) isn't a SLIT or PXM defined quantity.  It is really 
specific to HP cell machines.  For example, a machine configured with 
two cells will report three PXMs.  Two for the CPUs and one for the 
interleaved memory at magic PXM 255.  The firmware doesn't report SLIT 
information for PXM 255. The patch approximates the SLIT value for PXM 
255. I have attempted to arrive at code which doesn't break non-HP 
hardware configurations. I have assumed the way the initialization code 
was written that all NIDs require memory.  Otherwise 
reserve_pernode_space will fail.

My patch with modifications to CodingStyle is below.  Hopefully it's 
correct this time. Sorry for that inconvenience and my non-conformance ;-)

Bob

--- linux-2.6.2-orig/arch/ia64/kernel/acpi.c	2004-02-18 07:46:10.000000000 -0500
+++ linux-2.6.2/arch/ia64/kernel/acpi.c	2004-02-18 07:33:00.000000000 -0500
@@ -338,11 +338,16 @@
 #undef SLIT_DEBUG
 
 #define PXM_FLAG_LEN ((MAX_PXM_DOMAINS + 1)/32)
+#define	PXM_MAGIC	(255)
 
 static int __initdata srat_num_cpus;			/* number of cpus */
 static u32 __initdata pxm_flag[PXM_FLAG_LEN];
+static u32 __initdata mpxm_flag[PXM_FLAG_LEN];
 #define pxm_bit_set(bit)	(set_bit(bit,(void *)pxm_flag))
+#define	pxm_bit_clear(bit)	(clear_bit(bit, (void *)pxm_flag))
 #define pxm_bit_test(bit)	(test_bit(bit,(void *)pxm_flag))
+#define	mpxm_bit_set(bit)	(set_bit(bit, (void *) mpxm_flag))
+#define	mpxm_bit_test(bit)	(test_bit(bit, (void *) mpxm_flag))
 /* maps to convert between proximity domain and logical node ID */
 int __initdata pxm_to_nid_map[MAX_PXM_DOMAINS];
 int __initdata nid_to_pxm_map[MAX_NUMNODES];
@@ -424,6 +429,110 @@
 	num_memblks++;
 }
 
+static void __init
+acpi_pxm_magic_slit_fix (void)
+{
+	u8 distance, x;
+	int i, j, nid;
+#define	SLIT_IDENTITY	10
+
+
+	if (!pxm_bit_test(PXM_MAGIC) || slit_table->localities >= PXM_MAGIC)
+		return;
+
+	nid = pxm_to_nid_map[PXM_MAGIC];
+
+	for (distance = SLIT_IDENTITY*2, i = 0; i < slit_table->localities; i++) {
+		if (!pxm_bit_test(i))
+			continue;
+
+		for (j = 0; j < slit_table->localities; j++) {
+			if (!pxm_bit_test(j) || (i = j))
+				continue;
+
+			x = (slit_table->entry[i*slit_table->localities + j] + SLIT_IDENTITY) / 2;
+			distance = min(x, distance);
+		}
+	}
+
+	/*
+	 * Fill in distances for PXM magic.
+	 */
+
+	for (i = 0; i < numnodes;  i++) 
+		node_distance(i, nid) = distance;
+
+	for (i = 0; i < (numnodes - 1); i++)
+		node_distance(nid, i) = distance;
+
+	node_distance(nid, nid) = SLIT_IDENTITY;
+
+
+	return;
+}
+
+static void __init
+acpi_pxm_magic_fix (void)
+{
+	struct node_memblk_s *p;
+	int i, nnode, nid, cpu, pxm;
+
+
+	/*
+	 * If every nid has memory then we are done.
+	 */
+
+	for (nnode = 0, p = &node_memblk[0]; p < &node_memblk[num_memblks]; p++) 
+		if (!mpxm_bit_test(p->nid)) {
+			mpxm_bit_set(p->nid);
+			nnode++;
+		}
+	
+	/*
+	 * All nids with memory.
+	 */
+
+	if (nnode = numnodes) 
+		return;
+
+	/*
+	 * Change logical node id for nids without memory.
+	 * If we are removing a nid without memory, then
+	 * move that nid's cpus to nnode-1 which will become
+	 * the magic PXM's logical node id.  The node_cpu[X].nid
+	 * is the PXM but will change later to logical node
+	 * id.
+	 */
+
+	for (nid = 0, i = 0; i < numnodes; i++) 
+		if (mpxm_bit_test(i)) {
+			if (i = nid) {
+				nid++;
+				continue;
+			}
+
+			for (p = &node_memblk[0]; p < &node_memblk[num_memblks]; p++)
+				if (p->nid = i)
+					p->nid = nid;
+
+			pxm = nid_to_pxm_map[i];
+			pxm_to_nid_map[pxm] = nid;
+			nid_to_pxm_map[nid] = pxm;
+			nid++;
+		} else {
+			for (cpu = 0; cpu < srat_num_cpus; cpu++)
+				if (node_cpuid[cpu].nid = nid_to_pxm_map[i])
+					node_cpuid[cpu].nid = PXM_MAGIC;
+
+			pxm_to_nid_map[i] = nnode - 1;
+			pxm_bit_clear(nid_to_pxm_map[i]);
+		}
+
+	numnodes = nnode;
+
+	return;
+}
+
 void __init
 acpi_numa_arch_fixup (void)
 {
@@ -451,6 +560,8 @@
 	for (i = 0; i < num_memblks; i++)
 		node_memblk[i].nid = pxm_to_nid_map[node_memblk[i].nid];
 
+	acpi_pxm_magic_fix();
+
 	/* assign memory bank numbers for each chunk on each node */
 	for (i = 0; i < numnodes; i++) {
 		int bank;
@@ -468,8 +579,13 @@
 	printk(KERN_INFO "Number of logical nodes in system = %d\n", numnodes);
 	printk(KERN_INFO "Number of memory chunks in system = %d\n", num_memblks);
 
-	if (!slit_table) return;
+	if (!slit_table) 
+		return;
+
 	memset(numa_slit, -1, sizeof(numa_slit));
+
+	acpi_pxm_magic_slit_fix();
+
 	for (i=0; i<slit_table->localities; i++) {
 		if (!pxm_bit_test(i))
 			continue;







