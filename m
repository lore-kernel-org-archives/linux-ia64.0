From: chas williams <chas@cmf.nrl.navy.mil>
Date: Wed, 01 Aug 2001 20:59:22 +0000
Subject: Re: [Linux-ia64] still patching syscall into module
Message-Id: <marc-linux-ia64-105590693005981@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590693005967@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590693005967@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

in case anyone cares i think the following is the answer to my problem

	.globl module_syscall_stub
        alloc r42 = ar.pfs, 8, 3, 6, 0
        mov r41 = b0 
        mov r43 = r32
        mov r44 = r33
        mov r45 = r34
        mov r46 = r35
        mov r47 = r36
        mov r48 = gp
        ;;
        movl r15=<fptr adddress>
        ;;
        ld8 r16=[r15],8
        ;;
        ld8 gp=[r15]
        mov b6=r16
        br.call.sptk.many b0 = b6
        ;;
        mov ar.pfs = r42
        mov b0 = r41
        mov gp = r48

        br.ret.sptk.many b0
	.endp module_syscall_stub

perhaps someone could comment but i mostly just wrote this based on what
i read in the software developer's manual.  i allocate a little space on
the register stack, pass along the args (only 5 actually)  and then call
the routine in the module via its fptr (patched 'dynamically' at insmod)

after returning the gp is restored from the saved registers.  the old
rp is called (which should be ia64_leave_kernel or something similar)

