From: "Luck, Tony" <tony.luck@intel.com>
Date: Mon, 03 Dec 2001 20:12:07 +0000
Subject: [Linux-ia64] PATCH: performance problems with swiotlb.c
MIME-Version: 1
Content-Type: multipart/mixed; boundary="----_=_NextPart_000_01C17C36.C86F2550"
Message-Id: <marc-linux-ia64-105590698805583@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org

This message is in MIME format. Since your mail reader does not understand
this format, some or all of this message may not be legible.

------_=_NextPart_000_01C17C36.C86F2550
Content-Type: text/plain;
	charset="iso-8859-1"

This problem was found and this fix suggested by Dori Eldar here
at Intel (I just critiqued it for a while and pointed out some
corner cases that needed to be addressed).

There are performance problems with the current swiotlb.c bounce
buffer allocation code.  Users with large systems full of devices
that require bounce buffers can sometimes find that they need to
increase the number of bounce buffers available using the swiotlb
boot time option to avoid panicing when running out of buffers.
However, this can result in slow allocation/free of buffers as the
swiotlb code spends a lot of cpu time coalescing blocks.  On one
benchmark this fix raised ethernet throughput from around 40 Mb/s
to 95Mb/s while reducing cpu load from 100% to 20%.

The basis of the fix is to partition the space reserved for bounce
buffers into smaller segments so that we place an upper bound on
the amount of work needed to coalesce blocks.  In addition to the
performace boost, this patch also fixes one real bug that Dori
found while testing.  map_single() would pick a "stride" based on
the number of slots needed for the request ... but if this stride
is not a power of two, the "do { ... } while (index != wrap);" loop
can spin indefinitely. He changed that to use a stride of 1 because
he couldn't see the benefit of the larger stride ... nor can I ... e.g.
when looking for 5 slots you might look at an allocation map that
looks like this:

	3 <- look here, 3<5 so skip down 5 slots
	2
	1
	0
	5
	4 <- now look here, missing the large enough block that began
	     on the previous slot.

-Tony Luck



------_=_NextPart_000_01C17C36.C86F2550
Content-Type: application/octet-stream;
	name="patch-swiotlb"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: attachment;
	filename="patch-swiotlb"

diff -ru ../../REF/2.4.16-ia64-011128/arch/ia64/lib/swiotlb.c =
linux/arch/ia64/lib/swiotlb.c=0A=
--- ../../REF/2.4.16-ia64-011128/arch/ia64/lib/swiotlb.c	Wed Nov 28 =
16:55:04 2001=0A=
+++ linux/arch/ia64/lib/swiotlb.c	Mon Dec  3 11:41:51 2001=0A=
@@ -27,6 +27,16 @@=0A=
 #define ALIGN(val, align) ((unsigned long)	\=0A=
 	(((unsigned long) (val) + ((align) - 1)) & ~((align) - 1)))=0A=
 =0A=
+#define OFFSET(val,align) ((unsigned long)	\=0A=
+	                   ( (val) & ( (align) - 1)))=0A=
+=0A=
+/*=0A=
+ * Maximum allowable number of contiguous slabs to map, =0A=
+ * must be a power of 2.  What is the appropriate value ?=0A=
+ * The complexity of {map,unmap}_single is linearly dependent on this =
value.=0A=
+ */ =0A=
+#define IO_TLB_SEGSIZE	128=0A=
+=0A=
 /*=0A=
  * log of the size of each IO TLB slab.  The number of slabs is =
command line controllable.=0A=
  */=0A=
@@ -65,10 +75,15 @@=0A=
 setup_io_tlb_npages (char *str)=0A=
 {=0A=
 	io_tlb_nslabs =3D simple_strtoul(str, NULL, 0) << (PAGE_SHIFT - =
IO_TLB_SHIFT);=0A=
+=0A=
+	/* avoid tail segment of size < IO_TLB_SEGSIZE */  =0A=
+	io_tlb_nslabs =3D ALIGN(io_tlb_nslabs, IO_TLB_SEGSIZE);=0A=
+=0A=
 	return 1;=0A=
 }=0A=
 __setup("swiotlb=3D", setup_io_tlb_npages);=0A=
 =0A=
+=0A=
 /*=0A=
  * Statically reserve bounce buffer space and initialize bounce buffer =
data structures for=0A=
  * the software IO TLB used to implement the PCI DMA API.=0A=
@@ -88,12 +103,12 @@=0A=
 =0A=
 	/*=0A=
 	 * Allocate and initialize the free list array.  This array is =
used=0A=
-	 * to find contiguous free memory regions of size 2^IO_TLB_SHIFT =
between=0A=
-	 * io_tlb_start and io_tlb_end.=0A=
+	 * to find contiguous free memory regions of size up to =
IO_TLB_SEGSIZE=0A=
+	 * between io_tlb_start and io_tlb_end.=0A=
 	 */=0A=
 	io_tlb_list =3D alloc_bootmem(io_tlb_nslabs * sizeof(int));=0A=
 	for (i =3D 0; i < io_tlb_nslabs; i++)=0A=
-		io_tlb_list[i] =3D io_tlb_nslabs - i;=0A=
+ 		io_tlb_list[i] =3D IO_TLB_SEGSIZE - OFFSET(i, IO_TLB_SEGSIZE);=0A=
 	io_tlb_index =3D 0;=0A=
 	io_tlb_orig_addr =3D alloc_bootmem(io_tlb_nslabs * sizeof(char =
*));=0A=
 =0A=
@@ -120,7 +135,7 @@=0A=
 	if (size > (1 << PAGE_SHIFT))=0A=
 		stride =3D (1 << (PAGE_SHIFT - IO_TLB_SHIFT));=0A=
 	else=0A=
-		stride =3D nslots;=0A=
+		stride =3D 1; =0A=
 =0A=
 	if (!nslots)=0A=
 		BUG();=0A=
@@ -147,7 +162,8 @@=0A=
 =0A=
 				for (i =3D index; i < index + nslots; i++)=0A=
 					io_tlb_list[i] =3D 0;=0A=
-				for (i =3D index - 1; (i >=3D 0) && io_tlb_list[i]; i--)=0A=
+				for (i =3D index - 1; (OFFSET(i, IO_TLB_SEGSIZE) !=3D =
IO_TLB_SEGSIZE -1)=0A=
+				       && io_tlb_list[i]; i--)=0A=
 					io_tlb_list[i] =3D ++count;=0A=
 				dma_addr =3D io_tlb_start + (index << IO_TLB_SHIFT);=0A=
 =0A=
@@ -213,7 +229,8 @@=0A=
 	 */=0A=
 	spin_lock_irqsave(&io_tlb_lock, flags);=0A=
 	{=0A=
-		int count =3D ((index + nslots) < io_tlb_nslabs ? io_tlb_list[index =
+ nslots] : 0);=0A=
+		int count =3D ((index + nslots) < ALIGN(index + 1, IO_TLB_SEGSIZE) =
?=0A=
+			     io_tlb_list[index + nslots] : 0);=0A=
 		/*=0A=
 		 * Step 1: return the slots to the free list, merging the slots =
with=0A=
 		 * superceeding slots=0A=
@@ -224,7 +241,8 @@=0A=
 		 * Step 2: merge the returned slots with the preceeding slots, if=0A=
 		 * available (non zero)=0A=
 		 */=0A=
-		for (i =3D index - 1; (i >=3D 0) && io_tlb_list[i]; i--)=0A=
+		for (i =3D index - 1;  (OFFSET(i, IO_TLB_SEGSIZE) !=3D =
IO_TLB_SEGSIZE -1) &&=0A=
+		       io_tlb_list[i]; i--)=0A=
 			io_tlb_list[i] =3D ++count;=0A=
 	}=0A=
 	spin_unlock_irqrestore(&io_tlb_lock, flags);=0A=

------_=_NextPart_000_01C17C36.C86F2550--

