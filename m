From: Jim Wilson <wilson@cygnus.com>
Date: Wed, 16 Aug 2000 02:27:46 +0000
Subject: Re: [Linux-ia64] Re: gas dependency checker bug [forwarded message from Xavier Leroy]
Message-Id: <marc-linux-ia64-105590678205330@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205190@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205190@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

	While we're at it, I found a third case of missed RAW dependency.

        cmp.eq p6, p7 = r32, r33
        (p6) mov r8 = 1
        (p7) mov r8 = 0

This turns out to be a bug in the DV tables that we got from Intel.  The
pr-readers-nobr-nomovpr instruction class is missing addl and adds.  If
you use any instruction except addl/adds/mov, then the DV will be reported.

This instruction class is correct in the July 2000 version of the SDM.
See Vol 2, Appendix A, page A-21.  If I update that line by hand, then the
DV is reported for this testcase.  I don't want to update 21 pages of info
by hand, so I will ask Intel for updated copies of these tables.

The following patch fixes this.  This requires running the ia64-gen program
to rebuild the ia64-asmtab.c file.

Index: ia64-ic.tbl
=================================RCS file: /cvs/cvsfiles/devo/opcodes/ia64-ic.tbl,v
retrieving revision 1.3
diff -p -r1.3 ia64-ic.tbl
*** ia64-ic.tbl	2000/08/15 19:44:19	1.3
--- ia64-ic.tbl	2000/08/16 02:18:33
*************** pr-norm-writers-fp;	IC:pr-gen-writers-fp
*** 202,208 ****
  pr-norm-writers-int;	IC:pr-gen-writers-int[Field(ctype)=]
  pr-or-writers;	IC:pr-gen-writers-int[Field(ctype) in {or orcm}], IC:pr-gen-writers-int[Field(ctype) in {or.andcm and.orcm}]
  pr-readers-br;	br.call, br.cond, brl.call, brl.cond, br.ret, br.wexit, br.wtop, break.b, break, nop.b, nop, IC:ReservedBQP
! pr-readers-nobr-nomovpr;	add, addp4, and, andcm, break.f, break.i, break.m, break.x, break, chk.s, IC:chk-a, cmp, cmp4, IC:cmpxchg, IC:czx, dep, extr, IC:fp-arith, IC:fp-non-arith, fc, fchkf, fclrf, fcmp, IC:fetchadd, fpcmp, fsetc, fwb, getf, IC:invala-all, itc.i, itc.d, itr.i, itr.d, IC:ld, IC:ldf, IC:ldfp, IC:lfetch-all, mf, IC:mix, IC:mov-from-AR-M, IC:mov-from-AR-IM, IC:mov-from-AR-I, IC:mov-to-AR-M, IC:mov-to-AR-I, IC:mov-to-AR-IM, IC:mov-to-BR, IC:mov-from-BR, IC:mov-to-CR, IC:mov-from-CR, IC:mov-to-IND, IC:mov-from-IND, IC:mov-ip, IC:mov-immediate, IC:mov-to-PSR-l, IC:mov-to-PSR-um, IC:mov-from-PSR, IC:mov-from-PSR-um, movl, IC:mux, nop.f, nop.i, nop.m, nop.x, nop, or, IC:pack, IC:padd, IC:pavg, IC:pavgsub, IC:pcmp, IC:pmax, IC:pmin, IC:pmpy, IC:pmpyshr, popcnt, IC:probe-all, IC:psad, IC:pshl, IC:pshladd, IC:pshr, IC:pshradd, IC:psub, ptc.e, ptc.g, ptc.ga, ptc.l, ptr.d, ptr.i, IC:ReservedQP, rsm, setf, shl, shladd, shladdp4, shr, shrp, srlz.i, srlz.d, ssm, IC:st, IC:s!
tf, sub, sum, IC:sxt, sync, tak, tbit, thash, tnat, tpa, ttag, IC:unpack, IC:xchg, xma, xmpy, xor, IC:zxt
  pr-unc-writers-fp;	IC:pr-gen-writers-fp[Field(ctype)=unc]+11, fprcpa+11, fprsqrta+11, frcpa+11, frsqrta+11
  pr-unc-writers-int;	IC:pr-gen-writers-int[Field(ctype)=unc]+11
  pr-writers;	IC:pr-writers-int, IC:pr-writers-fp
--- 202,208 ----
  pr-norm-writers-int;	IC:pr-gen-writers-int[Field(ctype)=]
  pr-or-writers;	IC:pr-gen-writers-int[Field(ctype) in {or orcm}], IC:pr-gen-writers-int[Field(ctype) in {or.andcm and.orcm}]
  pr-readers-br;	br.call, br.cond, brl.call, brl.cond, br.ret, br.wexit, br.wtop, break.b, break, nop.b, nop, IC:ReservedBQP
! pr-readers-nobr-nomovpr;	add, addl, addp4, adds, and, andcm, break.f, break.i, break.m, break.x, chk.s, IC:chk-a, cmp, cmp4, IC:cmpxchg, IC:czx, dep, extr, IC:fp-arith, IC:fp-non-arith, fc, fchkf, fclrf, fcmp, IC:fetchadd, fpcmp, fsetc, fwb, getf, IC:invala-all, itc.i, itc.d, itr.i, itr.d, IC:ld, IC:ldf, IC:ldfp, IC:lfetch-all, mf, IC:mix, IC:mov-from-AR-M, IC:mov-from-AR-IM, IC:mov-from-AR-I, IC:mov-to-AR-M, IC:mov-to-AR-I, IC:mov-to-AR-IM, IC:mov-to-BR, IC:mov-from-BR, IC:mov-to-CR, IC:mov-from-CR, IC:mov-to-IND, IC:mov-from-IND, IC:mov-ip, IC:mov-to-PSR-l, IC:mov-to-PSR-um, IC:mov-from-PSR, IC:mov-from-PSR-um, movl, IC:mux, nop.f, nop.i, nop.m, nop.x, or, IC:pack, IC:padd, IC:pavg, IC:pavgsub, IC:pcmp, IC:pmax, IC:pmin, IC:pmpy, IC:pmpyshr, popcnt, IC:probe-all, IC:psad, IC:pshl, IC:pshladd, IC:pshr, IC:pshradd, IC:psub, ptc.e, ptc.g, ptc.ga, ptc.l, ptr.d, ptr.i, IC:ReservedQP, rsm, setf, shl, shladd, shladdp4, shr, shrp, srlz.i, srlz.d, ssm, IC:st, IC:stf, sub, sum, IC:s!
xt, sync, tak, tbit, thash, tnat, tpa, ttag, IC:unpack, IC:xchg, xma, xmpy, xor, IC:zxt
  pr-unc-writers-fp;	IC:pr-gen-writers-fp[Field(ctype)=unc]+11, fprcpa+11, fprsqrta+11, frcpa+11, frsqrta+11
  pr-unc-writers-int;	IC:pr-gen-writers-int[Field(ctype)=unc]+11
  pr-writers;	IC:pr-writers-int, IC:pr-writers-fp

