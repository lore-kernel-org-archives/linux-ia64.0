From: Jack Steiner <steiner@sgi.com>
Date: Mon, 12 Feb 2001 22:25:38 +0000
Subject: [Linux-ia64] ia64_get_dcr problem
Message-Id: <marc-linux-ia64-105590693005143@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Is this a GCC problem or a problem with the asm/ia64/processor.h
inline functions??


I used the ia64_set_dcr & ia64_get_dcr functions in
a loop & got bad code. I had references to both ia64_get_dcr 
in ia64_set_dcr in the loop. The "get" was optimized out of the loop &
did not see the result of the "set".

If I add "volatile" to the ia64_get_dcr asm statement, I can 
avoid the problem. But I am not sure whether this is the correct
solution. (I hit a similar problem with ia64_get_irr0() earlier too).


I am using the "2.96-ia64-000717 snap 001117" compiler.



Source (stupid test but illustrates the problem):

        void
        dcrtest() {

                long    i, dcr;
                for (i=0; i<10; i++) {
                        printk("0x%lx\n", ia64_get_dcr());
                        ia64_set_dcr(0x5555);
                }
        }


Generated code:
         <dcrtest.0>        alloc r36=ar.pfs,0,5,2,0  
         <dcrtest.1>        mov r34=cr.dcr                      <<< get
         <dcrtest.2>        mov r35=rp  
         <dcrtest+0x10.0>        mov r33!845  
         <dcrtest+0x10.1>        mov r32=9  
         <dcrtest+0x10.2>        nop.i 0  

         <dcrtest+0x20.0>        addl r37=-1091248,gp;;
         <dcrtest+0x20.1>        mov r38=r34  
         <dcrtest+0x20.2>        nop.i 0  
         <dcrtest+0x30.0>        ld8 r37=[r37]  
         <dcrtest+0x30.1>        nop.i 0  
         <dcrtest+0x30.2>        br.call.sptk.many rp=printk;;
         <dcrtest+0x40.0>        mov cr.dcr=r33;;               <<< set
         <dcrtest+0x40.1>        srlz.d  
         <dcrtest+0x40.2>        adds r32=-1,r32;;
         <dcrtest+0x50.0>        cmp.lt p7,p6=r32,r0  
         <dcrtest+0x50.1>        nop.i 0  
         <dcrtest+0x50.2>   (p6) br.cond.dptk.few dcrtest+0x20  

         <dcrtest+0x60.0>        nop.m 0  
         <dcrtest+0x60.1>        mov.i ar.pfs=r36  
         <dcrtest+0x60.2>        mov rp=r35  
         <dcrtest+0x70.0>        nop.m 0  
         <dcrtest+0x70.1>        nop.i 0  
         <dcrtest+0x70.2>        br.ret.sptk.many rp;;

-- 
Thanks

Jack Steiner    (651-683-5302)   (vnet 233-5302)      steiner@sgi.com


