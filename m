From: Francois WELLENREITER <francois.wellenreiter@bull.net>
Date: Wed, 05 Apr 2006 12:16:17 +0000
Subject: Re: 2.6.16 fails to resume after INIT in user space
Message-Id: <4433B511.1010301@bull.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <12848.1144211334@kao2.melbourne.sgi.com>
In-Reply-To: <12848.1144211334@kao2.melbourne.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org



                                    Hi Keith and all,

          concerning this issue, it works well on Bull Novascale 5160.

However, have you tested INIT feature with a 2.6.15 kernel ?
Indeed, since this kernel version, I have noticed that on Intel Tiger
machines,
the behavior was exactly the same than the description you are giving
here below.
After a more detailed investigation with an ITP, I have seen that the
trouble ever happens
when executing the following code :

________________________________________

ia64_old_stack:
    add regs=3DMCA_PT_REGS_OFFSET, r3
    mov b0=3Dr2            // save return address
    GET_IA64_MCA_DATA(temp2)
    LOAD_PHYSICAL(p0,temp1,1f)
    ;;
    mov cr.ipsr=3Dr0
    mov cr.ifs=3Dr0
    mov cr.iip=3Dtemp1
    ;;
    invala
    rfi   <---------------------------------------
________________________________________

After rfi instruction, the kernel INIT handler is called again instead
of executing the code
located at "temp1" address.
Since we provide our own SAL version on NS5160 machines, I think that
the problem might be located at the SAL level,

My comprehension is that there might be a misfunctioning in the SAL
concerning INIT event management
and when psr.mc bit is forced to 0 again, the previous INIT signal is
not filtered anymore, and the entire INIT call chain
is executed again. But it is just a personal interpretation and I have
no proof about this.
This point has been submitted to Intel gurus and is under investigation.

Best regards,

                                                                       =20
         Francois WELLENREITER

>2.6.16 on SN2, compiled with gcc 3.3.3, no KDB.
>
>The SN2 controller 'NMI' command sends INIT to all processors, one as
>monarch, the rest as slaves.  If all the processors are in kernel space
>(including idle) then INIT resumes after dumping the process list.  If
>any of the processors are in user space then INIT claims to resume but
>gets something wrong, the system becomes dead.
>
>Send first NMI
>
>  Entered OS INIT handler. PSP=FFe301a0 cpu=3D0 monarch=3D0
>  cpu 0, INIT occurred in user space, original stack not modified
>  Entered OS INIT handler. PSP=FFe301a0 cpu=3D3 monarch=3D0
>  Entered OS INIT handler. PSP=FFe301a0 cpu=3D2 monarch=3D0
>  Entered OS INIT handler. PSP=FFe301a0 cpu=3D1 monarch=3D1
>  Delaying for 5 seconds...
>  Processes interrupted by INIT - 0 (cpu 1 task 0xe00000b47a4b8000) 0 (cpu=
 2 task 0xe00000b47a4e8000) 0 (cpu 3 task 0xe00000b47a500000)
>
>  ... process dump ...
>
>  INIT dump complete.  Monarch on cpu 1 returning to normal service.
>  Slave on cpu 0 returning to normal service.
>  Slave on cpu 3 returning to normal service.
>  Slave on cpu 2 returning to normal service.
>
>  ... No response ...
>
>Send second NMI
>
>  Entered OS INIT handler. PSP=FFe301a0 cpu=3D3 monarch=3D0
>  Entered OS INIT handler. PSP=FFe301a0 cpu=3D0 monarch=3D0
>  cpu 0, INIT inconsistent previous current and r13, original stack not mo=
dified
>  Entered OS INIT handler. PSP=FFe301a0 cpu=3D2 monarch=3D0
>  Entered OS INIT handler. PSP=FFe301a0 cpu=3D1 monarch=3D1
>  Delaying for 5 seconds...
>  Processes interrupted by INIT - 0 (cpu 1 task 0xe00000b47a4b8000) 0 (cpu=
 2 task 0xe00000b47a4e8000) 0 (cpu 3 task 0xe00000b47a500000)
>
>cpu 0 was running in user space during the first NMI, so the original
>stack was not modified.  On the second NMI, current for cpu 0 does not
>match r13.  Which means that something went wrong when processing the
>first NMI while the process was in user space.
>
>I am still investigating this problem, but any other eyes on the code
>would be appreciated.
>
>-
>To unsubscribe from this list: send the line "unsubscribe linux-ia64" in
>the body of a message to majordomo@vger.kernel.org
>More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
> =20
>
