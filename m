From: Mario Smarduch <cms063@email.mot.com>
Date: Thu, 07 Nov 2002 17:14:54 +0000
Subject: Re: [Linux-ia64] [PATCH] Performance Patch for TLB misses
Message-Id: <marc-linux-ia64-105590709805352@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805350@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805350@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

Christian Hildner wrote:

> Hi,
>
> I created a patch that will (hopefully) increase the performance for TLB
> miss handling.
>
> - enlarge the distance between rsm psr.dt and srlz (the movl do not need
> data access)
>
> - let the processor check for the case of page not present (because for
> useable systems the common case is that the page is present, so optimize
> for that and drop the conditional branch)
>
> - let the processor also check for privilege level because it's very
> very rare

Wouldn't removal of this possibly cause cached and uncahced mappings
to same page?

- mario.

>
>
> The second modification will result (rarely) in the insertion of an
> unused TLB entry. But this entry will be overwritten with the useable
> entry when the page is swapped in. The time needed for the insertion of
> the TLB entry and the additional interruption will be neglectible
> compared to the time needed for swapping in.
>
> Since I'am waiting for Itanium 2 (Itanium 1 does not have any relevance
> nowadays) I have done no performance testing. All Itanium 2 owners are
> invited for testing.
>
> Please tell me your comments.
>
> Christian
>
>   ------------------------------------------------------------------------
> --- ivt.S_orig  Tue Mar 19 11:22:28 2002
>  ivt.S  Thu Nov  7 13:53:02 2002
> @@ -114,8 +114-,8 @@
>          *      - the faulting virtual address has no L1, L2, or L3 mappi=
ng
>          */
>         mov r16=3Dcr.ifa                          // get address that cau=
sed the TLB miss
> -       ;;
>         rsm psr.dt                              // use physical addressin=
g for data
>         ;;
>         mov r31=3Dpr                              // save the predicate r=
egisters
>         mov r19=3DIA64_KR(PT_BASE)                // get page table base =
address
>         shl r21=3Dr16,3                           // shift bit 60 into si=
gn bit
> @@ -125,7 +124-,6 @@
>         shr.u r18=3Dr16,PGDIR_SHIFT               // get bits 33-63 of th=
e faulting address
>         ;;
>  (p7)   dep r17=3Dr17,r19,(PAGE_SHIFT-3),3        // put region number bi=
ts in place
> -       srlz.d                                  // ensure "rsm psr.dt" ha=
s taken effect
>  (p6)   movl r19=3D__pa(SWAPPER_PGD_ADDR)         // region 5 is rooted a=
t swapper_pg_dir
>  (p6)   shr.u r21=3Dr21,PGDIR_SHIFT+PAE-_SHIFT
>  (p7)   shr.u r21=3Dr21,PGDIR_SHIFT+PAE-_SHIFT-3
> @@ -135,6 +134-,7 @@
>         cmp.eq p7,p6=3D0,r21                      // unused address bits =
all zeroes?
>         shr.u r18=3Dr16,PMD_SHIFT                 // shift L2 index into =
position
>         ;;
>         srlz.d                                  // ensure "rsm psr.dt" ha=
s taken effect
>         ld8 r17=3D[r17]                           // fetch the L1 entry (=
may be 0)
>         ;;
>  (p7)   cmp.eq p6,p7=3Dr17,r0                     // was L1 entry NULL?
> @@ -212,9 +210-,6 @@
>  1:     ld8 r18=3D[r17]                           // read L3 PTE
>         ;;
>         mov b0=3Dr29
> -       tbit.z p6,p0=3Dr18,_PAGE_P_BIT            // page present bit cle=
ared?
> -(p6)   br.cond.spnt page_fault
> -       ;;
>         itc.i r18
>         ;;
>  #ifdef CONFIG_SMP
> @@ -250,9 +244-,6 @@
>  1:     ld8 r18=3D[r17]                           // read L3 PTE
>         ;;
>         mov b0=3Dr29
> -       tbit.z p6,p0=3Dr18,_PAGE_P_BIT            // page present bit cle=
ared?
> -(p6)   br.cond.spnt page_fault
> -       ;;
>         itc.d r18
>         ;;
>  #ifdef CONFIG_SMP
> @@ -274,12 +268-,11 @@
>         DBG_FAULT(3)
>         mov r16=3Dcr.ifa          // get address that caused the TLB miss
>         movl r17=3DPAGE_KERNEL
> -       mov r21=3Dcr.ipsr
>         movl r19=3D(((1 << IA64_MAX_PHYS_BITS) - 1) & +AH4-0xfff)
>         mov r31=3Dpr
>         ;;
>  #ifdef CONFIG_DISABLE_VHPT
> -       shr.u r22=3Dr16,61                        // get the region numbe=
r into r21
>         shr.u r22=3Dr16,61                        // get the region number
>         ;;
>         cmp.gt p8,p0=3D6,r22                      // user mode
>         ;;
> @@ -289,16 +280-,13 @@
>  (p8)   mov r29=B0                              // save b0
>  (p8)   br.cond.dptk itlb_fault
>  #endif
> -       extr.u r23=3Dr21,IA64_PSR_CPL0_BIT,2      // extract psr.cpl
>         and r19=3Dr19,r16         // clear ed, reserved bits, and PTE con=
trol bits
>         shr.u r18=3Dr16,57        // move address bit 61 to bit 4
>         ;;
>         andcm r18=3D0x10,r18      // bit 4=3D+AH4-address-bit(61)
> -       cmp.ne p8,p0=3Dr0,r23     // psr.cpl !=3D 0?
>         or r19=3Dr17,r19          // insert PTE control bits into r19
>         ;;
>         or r19=3Dr19,r18          // set bit 4 (uncached) if the access w=
as to region 6
> -(p8)   br.cond.spnt page_fault
>         ;;
>         itc.i r19               // insert the TLB entry
>         mov pr=3Dr31,-1
> @@ -318,7 +308-,7 @@
>         mov r31=3Dpr
>         ;;
>  #ifdef CONFIG_DISABLE_VHPT
> -       shr.u r22=3Dr16,61                        // get the region numbe=
r into r21
>         shr.u r22=3Dr16,61                        // get the region number
>         ;;
>         cmp.gt p8,p0=3D6,r22                      // access to region 0-5
>         ;;
> @@ -328,15 +318-,11 @@
>  (p8)   mov r29=B0                              // save b0
>  (p8)   br.cond.dptk dtlb_fault
>  #endif
> -       extr.u r23=3Dr21,IA64_PSR_CPL0_BIT,2      // extract psr.cpl
>         tbit.nz p6,p7=3Dr20,IA64_ISR_SP_BIT       // is speculation bit o=
n?
>         and r19=3Dr19,r16         // clear ed, reserved bits, and PTE con=
trol bits
>         shr.u r18=3Dr16,57        // move address bit 61 to bit 4
>         ;;
>         andcm r18=3D0x10,r18      // bit 4=3D+AH4-address-bit(61)
> -       cmp.ne p8,p0=3Dr0,r23
> -(p8)   br.cond.spnt page_fault
> -
>         dep r21=3D-1,r21,IA64_PSR_ED_BIT,1
>         or r19=3Dr19,r17          // insert PTE control bits into r19
>         ;;
> @@ -1412,3 +138-,5 @@
>  // 0x7f00 Entry 67 (size 16 bundles) Reserved
>         DBG_FAULT(67)
>         FAULT(67)


