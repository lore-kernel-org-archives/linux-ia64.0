From: Keith Owens <kaos@sgi.com>
Date: Wed, 01 Nov 2006 05:46:43 +0000
Subject: Re: KDB errors from kdba_mca_init on HP rx8620 running SLES9 SP3
Message-Id: <1618.1162360003@kao2.melbourne.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Alan Tyson (on Tue, 31 Oct 2006 18:45:54 +0000) wrote:
>Hi Keith,
>
>When running SLES9 SP3, which has KDB compiled in, it is not possible to
>enter into KDB or LKCD when a TC (transfer control) command is issued. 
>TC results in the OS init handler running and calling kdba_mca_init() 
>which gives the following error:
>
> kdba_mca_init: not enough data in pal_min_state_area for kdb backtrace, cpu 3
>
>This error results in the following some time later on:
> kdba_release_init_slave_stack: INIT slave tripped on cpu 0 when not in 
> kdb,should never happen
>
>The reason for the initial error is that kdba_mca_init() expects that 
>the floating point registers were saved by SAL when in fact they were 
>not.  The SAL spec states that it is not necessary to store them and, 
>in the interests of NMRAM real estate, the HP rx7620 and rx8620 systems 
>do not.
>
>What would be the down-side of ignoring the valid.fr bit?  I notice that
>cr and minstate bits seem to have been ignored in previous changes.  

If the salinfo record does not contain the floating point registers
then the corresponding fields in struct pt_regs that is built by KDB
will be populated with garbage.  It should not affect backtrace, gcc
never stores addresses in the floating point registers.

