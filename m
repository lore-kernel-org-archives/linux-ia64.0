From: "David S. Miller" <davem@davemloft.net>
Date: Fri, 25 Mar 2005 02:29:16 +0000
Subject: Re: [PATCH] add a clear_pages function to clear pages of higher
Message-Id: <20050324182916.661934df.davem@davemloft.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.58.0503101229420.13911@schroedinger.engr.sgi.com>
	<200503111008.12134.vda@port.imtp.ilyichevsk.odessa.ua>
	<Pine.LNX.4.58.0503161720570.1787@schroedinger.engr.sgi.com>
	<200503181154.37414.vda@port.imtp.ilyichevsk.odessa.ua>
	<Pine.LNX.4.58.0503180652350.15022@schroedinger.engr.sgi.com>
	<20050318192808.GB38053@muc.de>
	<16963.2075.713737.485070@napali.hpl.hp.com>
	<Pine.LNX.4.58.0503241038040.5663@schroedinger.engr.sgi.com>
	<20050324110336.488241c4.davem@davemloft.net>
	<Pine.LNX.4.58.0503241449070.7119@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.58.0503241449070.7119@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: Christoph Lameter <clameter@sgi.com>
Cc: davidm@hpl.hp.com, ak@muc.de, clameter@sgi.com, vda@port.imtp.ilyichevsk.odessa.ua, haveblue@us.ibm.com, akpm@osdl.org, linux-kernel@vger.kernel.org, mel@csn.ul.ie, linux-ia64@vger.kernel.org, Jens.Maurer@gmx.net

On Thu, 24 Mar 2005 14:49:55 -0800 (PST)
Christoph Lameter <clameter@engr.sgi.com> wrote:

> Could you help me fix up this patch replacing the old clear_pages patch?

Ok, first you need to mark the order and gfp arguments as unsigned
for mm/page_alloc.c:prep_zero_page() so that it matches the prototype
you added to include/linux/gfp.h else the compiler warns a lot.

Next, in the same function in mm/page_alloc.c, "PageHighmem()" is typo'd, i=
t should be
"PageHighMem()".

The clear_cold() call on the next line needs a semicolon.

Erm... were any of your test builds done with the new CONFIG_CLEAR_COLD
option enabled? :-)

Next, replace your arch/sparc64/lib/clear_page.S diff with this one and
things would be working and we'll be using the proper temporal vs.
non-temporal stores on that platform.

=3D=3D=3D arch/sparc64/lib/clear_page.S 1.1 vs edited =3D=3D--- 1.1/arch/sp=
arc64/lib/clear_page.S	2004-08-08 19:54:07 -07:00
+++ edited/arch/sparc64/lib/clear_page.S	2005-03-24 15:56:33 -08:00
@@ -72,26 +72,34 @@
 	mov		1, %o4
=20
 clear_page_common:
-	VISEntryHalf
 	membar		#StoreLoad | #StoreStore | #LoadStore
-	fzero		%f0
 	sethi		%hi(PAGE_SIZE/64), %o1
 	mov		%o0, %g1		! remember vaddr for tlbflush
-	fzero		%f2
 	or		%o1, %lo(PAGE_SIZE/64), %o1
-	faddd		%f0, %f2, %f4
-	fmuld		%f0, %f2, %f6
-	faddd		%f0, %f2, %f8
-	fmuld		%f0, %f2, %f10
=20
-	faddd		%f0, %f2, %f12
-	fmuld		%f0, %f2, %f14
-1:	stda		%f0, [%o0 + %g0] ASI_BLK_P
+#define PREFETCH(x, y)	prefetch x, y
+#define PREFETCH_CODE	2
+
+	PREFETCH([%o0 + 0x000], PREFETCH_CODE)
+	PREFETCH([%o0 + 0x040], PREFETCH_CODE)
+	PREFETCH([%o0 + 0x080], PREFETCH_CODE)
+	PREFETCH([%o0 + 0x0c0], PREFETCH_CODE)
+	PREFETCH([%o0 + 0x100], PREFETCH_CODE)
+	PREFETCH([%o0 + 0x140], PREFETCH_CODE)
+	PREFETCH([%o0 + 0x180], PREFETCH_CODE)
+1:
+	stx		%g0, [%o0 + 0x00]
+	stx		%g0, [%o0 + 0x08]
+	stx		%g0, [%o0 + 0x10]
+	stx		%g0, [%o0 + 0x18]
+	stx		%g0, [%o0 + 0x20]
+	stx		%g0, [%o0 + 0x28]
+	stx		%g0, [%o0 + 0x30]
+	stx		%g0, [%o0 + 0x38]
+	PREFETCH([%o0 + 0x1c0], PREFETCH_CODE)
 	subcc		%o1, 1, %o1
 	bne,pt		%icc, 1b
 	 add		%o0, 0x40, %o0
-	membar		#Sync
-	VISExitHalf
=20
 	brz,pn		%o4, out
 	 nop
@@ -101,5 +109,32 @@
 	stw		%o2, [%g6 + TI_PRE_COUNT]
=20
 out:	retl
+	 nop
+
+	.globl		clear_cold
+clear_cold:		/* %o0=DEst, %o1=3Dorder */
+	sethi		%hi(PAGE_SIZE/64), %o2
+	clr		%o4
+	or		%o2, %lo(PAGE_SIZE/64), %o2
+	sllx		%o2, %o1, %o1
+	VISEntryHalf
+	membar		#StoreLoad | #StoreStore | #LoadStore
+	fzero		%f0
+	fzero		%f2
+	faddd		%f0, %f2, %f4
+	fmuld		%f0, %f2, %f6
+	faddd		%f0, %f2, %f8
+	fmuld		%f0, %f2, %f10
+
+	faddd		%f0, %f2, %f12
+	fmuld		%f0, %f2, %f14
+2:	stda		%f0, [%o0 + %g0] ASI_BLK_P
+	subcc		%o1, 1, %o1
+	bne,pt		%icc, 2b
+	 add		%o0, 0x40, %o0
+	membar		#Sync
+	VISExitHalf
+
+	retl
 	 nop
=20

