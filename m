From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Tue, 10 Dec 2002 02:33:38 +0000
Subject: RE: [Linux-ia64] unalinged access by loadpair instruction
Message-Id: <marc-linux-ia64-105590709805531@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805518@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805518@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

>>>>> On Mon, 9 Dec 2002 14:59:30 -0800, "Luck, Tony" <tony.luck@intel.com>=
 said:

  Tony> You do recall correctly ... checking the archives, I posted a
  Tony> patch on October 16, 2001.  I did fix the floating point case
  Tony> back then too ... in fact my post claims to include the patch
  Tony> for both integer and FP.  But I must have attached the wrong
  Tony> patch file.  I've long since deleted all my 2.4.10 trees, so
  Tony> I'd have to reconstruct from scratch (can't do it from memory,
  Tony> those neurons have been re-assigned :-(

OK, it looks like the fix is pretty straight-forward.  The patch below
_should_ work, though I haven't tested it extensively.

Hideki, can you try it out?  BTW: I think your test program is buggy.
The core-loop isn't right because br.ctop renames by one register
position, not two.  I attached a version of the test program which
does what you wanted.

	--david

=3D=3D=3D arch/ia64/kernel/unaligned.c 1.6 vs edited =3D=3D--- 1.6/arch/ia6=
4/kernel/unaligned.c	Thu Mar 14 00:28:41 2002
+++ edited/arch/ia64/kernel/unaligned.c	Mon Dec  9 18:24:54 2002
@@ -486,7 +486,21 @@
 	DPRINT("*0x%lx=3D0x%lx NaT=3D%d new unat: %p=3D%lx\n", addr, val, nat, (v=
oid *) unat,*unat);
 }
=20
-#define IA64_FPH_OFFS(r) (r - IA64_FIRST_ROTATING_FR)
+/*
+ * Return the (rotated) index for floating point register REGNUM (REGNUM m=
ust be in the
+ * range from 32-127, result is in the range from 0-95.
+ */
+static inline unsigned long
+fph_index (struct pt_regs *regs, long regnum)
+{
+	unsigned long rrb_fr =3D (regs->cr_ifs >> 25) & 0x7f;
+
+	regnum -=3D IA64_FIRST_ROTATING_FR;
+	regnum +=3D rrb_fr;
+	if (regnum >=3D 96)
+		regnum -=3D 96;
+	return regnum;
+}
=20
 static void
 setfpreg (unsigned long regnum, struct ia64_fpreg *fpval, struct pt_regs *=
regs)
@@ -507,7 +521,7 @@
 	 */
 	if (regnum >=3D IA64_FIRST_ROTATING_FR) {
 		ia64_sync_fph(current);
-		current->thread.fph[IA64_FPH_OFFS(regnum)] =3D *fpval;
+		current->thread.fph[fph_index(regs, regnum)] =3D *fpval;
 	} else {
 		/*
 		 * pt_regs or switch_stack ?
@@ -566,7 +580,7 @@
 	 */
 	if (regnum >=3D IA64_FIRST_ROTATING_FR) {
 		ia64_flush_fph(current);
-		*fpval =3D current->thread.fph[IA64_FPH_OFFS(regnum)];
+		*fpval =3D current->thread.fph[fph_index(regs, regnum)];
 	} else {
 		/*
 		 * f0 =3D 0.0, f1=3D 1.0. Those registers are constant and are thus
----------------------------------------------------
#define n 100

double d[n],d2[n+1];

main() {
    int i,j;

    for (i =3D 0; i < n; i++)  {
	    d[i] =3D i;
	    d2[i] =3D 0.0;
    }
    copy_by_loadpair(&d, &d2, n/2-1);
    for (i =3D 0; i < n; i++) {
	    if (d2[i] !=3D i)
		    printf("d2[%d] =3D %f, should be d[%d]=3D%f\n",
			   i, d2[i], i, d[i]);
    }
}

----------------------------------------------------
	.file	"a.c"
	.pred.safe_across_calls p1-p5,p16-p63
.text
	.align 16
	.global copy_by_loadpair
	.proc copy_by_loadpair
copy_by_loadpair:
        alloc   r8=3Dar.pfs,3,6,0,0 ;;
        mov     r15=3Dr32
        mov     r2=3Dr33
        add     r3=3D8,r33
        mov     ar.lc=3Dr34
        mov     pr.rot=3D0x10000
        mov     ar.ec=3D5 ;;
L1:
  (p16) ldfpd   f32,f37=3D[r15],16
  (p20) stfd    [r2]=F36,16
  (p20) stfd    [r3]=F41,16
        br.ctop.sptk    L1;;
        br.ret.sptk.many        b0 ;;
	.endp get_by_loadpair

