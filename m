From: Francois WELLENREITER <francois.wellenreiter@bull.net>
Date: Tue, 10 Jan 2006 15:36:46 +0000
Subject: INIT handler return does not work
Message-Id: <43C3D48E.5040206@bull.net>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="------------080300010103050708080905"
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org

This is a multi-part message in MIME format.
--------------080300010103050708080905
Content-Transfer-Encoding: 7bit
Content-Type: text/plain; charset=ISO-8859-1



                                           Hi everyone,


          first of all, my best wishes for this new year 2006.

Second, I have worked on INIT handler code for BULL NovaScale machines
and it appeared that return code do not work well due to a false argument
returned by OS_INIT function (in fact the pal_min_state pointer
physical address [recorded in r22 register] is not uncached as it is
specified).
The reason is that the computation of this register is not well done,
we have a virtual address in region 6 (souding like 0xC00000007F.....)
to be converted into an uncached physical address (0x800000007F....).
I think that the patch in attachment with this mail may correct this error.
Best regards,


                                              Francois WELLENREITER

--------------080300010103050708080905
Content-Transfer-Encoding: 7bit
Content-Type: text/x-patch;
 name="correct_init_return.patch"
Content-Disposition: inline;
 filename="correct_init_return.patch"

--- linux-2.6.15_reference/arch/ia64/kernel/mca_asm.S	2006-01-03 04:21:10.000000000 +0100
+++ linux-2.6.15_modified/arch/ia64/kernel/mca_asm.S	2006-01-10 16:10:31.000000000 +0100
@@ -847,7 +847,7 @@
 	;;
 	mov cr.iim=temp3
 	mov cr.iha=temp4
-	dep r22=0,r22,62,2	// pal_min_state, physical, uncached
+	dep r22=0,r22,62,1	// pal_min_state, physical, uncached
 	mov IA64_KR(CURRENT)=r21
 	ld8 r8=[temp1]		// os_status
 	ld8 r10=[temp2]		// context

--------------080300010103050708080905--
