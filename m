From: "Hideki Yamamoto" <hideki@hpc.bs1.fc.nec.co.jp>
Date: Mon, 09 Dec 2002 14:28:45 +0000
Subject: [Linux-ia64] unalinged access by loadpair instruction
Message-Id: <marc-linux-ia64-105590709805518@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

 Hi everyone,

 When unaligned access is happened by loadpair
 instruction, reloading by kernel is wrong.
=20
 When unalined access is happeded by loadpair
 instruction in NORMAL loop, it is no problem.
 Please try to run the attached programs(c.c and a.s)=20
 compiled by gcc.

 However, When it is happned by loadpair instruction in
 SWP loop, it fails to reload the data.
 Please try to run the attached programs(c.c and aa.s)
 compiled by gcc. aa.s is included loadpair in SWP loop.
 If there is no happening, please change the n
 parameter to bigger number.

 Sorry, I could not isolate whether or not it is caused
 by HW bug or Kernel problem.

 Let me know somebody understood the cause why it is happened.

 Thanks.

-- c.c
#define n 100
    double d[n],d2[n+1];
main() {
    int i,j;

    for( i =3D 0; i < n; i++ ) {
        d[i] =3D 123.0;
        d2[i] =3D 0.0;
    }
    // verify
    for( i =3D 0; i < n; i++ ) {
        if( d[i] !=3D 123.0 ) {
            printf("Assignment to d[%d] is wrong\n", i);
            exit(-1);
        }
    }
    printf("Verify is ok\n");
    copy_by_loadpair(&d, &d2, n);
    for( i =3D 0; i < n; i++ ) {
        if( d2[i] !=3D 123.0 ) {
            printf("Something is wrong!!\n d2[%d] =3D %f(should be d[%d]=3D=
%f)\n", i, d2[i], i, d[i]);
            printf("%f\n", d2[i+1]);
        }
    }
}

-- a.s=20
	.file	"a.c"
	.pred.safe_across_calls p1-p5,p16-p63
.text
	.align 16
	.global copy_by_loadpair#
	.proc copy_by_loadpair#
copy_by_loadpair:
 {   .mmi
        alloc   r8=3Dar.pfs,3,0,0,0 ;;                     //0:  1   19
        nop.m   0
        add     r17=3D1,r0
 }
L1:
 {   .mii
        ldfpd   f6,f7=3D[r32]                                 //1:  2    4
        add     r2=3D8,r33                                 //1:  3    8
        nop.i   0
 }
 {   .mmi
        nop.m   0 ;;                              //1:  3    6
        stfd    [r33]=F6
        add     r33=3D8,r33
 }
 {   .mmi
        nop.m   0 ;;                               //10:  3    7
        stfd    [r2]=F7                                  //19:  3    9
        add     r32=3D8,r32;;
 }
 {   .mib
        cmp4.ne p8,p0=3Dr17,r34
        add     r17=3D1,r17
  (p8)  br.cond.dpnt.many       L1 ;;                 //7:  3   19
 }
 {   .mib
        nop.m   0
        nop.i   0
        br.ret.sptk.many        b0 ;;                    //19:  4   10
 }
	.endp get_by_loadpair#
--
	.file	"a.c"
	.pred.safe_across_calls p1-p5,p16-p63
.text
	.align 16
	.global copy_by_loadpair#
	.proc copy_by_loadpair#
copy_by_loadpair:
 {   .mmi
        alloc   r8=3Dar.pfs,3,6,0,0 ;;
        nop.m   0
        add     r17=3D1,r0
 }
 {   .mmi
        add     r15=3D0,r32
        add     r2=3D0,r33
        add     r3=3D8,r33;;
 }
 {   .mii
        nop.m   0
        mov     ar.lc=3Dr34
        nop.i   0 ;;
 }
 {   .mii
        nop.m   0
        mov     pr.rot=3D0x10000 ;;
        mov     ar.ec=3D5 ;;
 }
L1:
 {   .mmi
  (p16) ldfpd   f32,f33=3D[r15]
  (p16) add     r15=3D8,r15
        nop.i   0
 }
 {   .mmb
  (p20) stfd    [r3]=F37,8
        //nop.m   0
  (p20) stfd    [r2]=F36,8
        br.ctop.sptk    L1
 }
 {   .mib
        nop.m   0
        nop.i   0
        br.ret.sptk.many        b0 ;;                    //19:  4   10
 }
	.endp get_by_loadpair#

