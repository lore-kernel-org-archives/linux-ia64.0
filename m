From: Alan Tyson <atyson@hp.com>
Date: Tue, 31 Oct 2006 18:45:54 +0000
Subject: KDB errors from kdba_mca_init on HP rx8620 running SLES9 SP3
Message-Id: <454799E2.5070203@hp.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi Keith,

When running SLES9 SP3, which has KDB compiled in, it is not possible to
enter into KDB or LKCD when a TC (transfer control) command is issued. 
TC results in the OS init handler running and calling kdba_mca_init() 
which gives the following error:

 kdba_mca_init: not enough data in pal_min_state_area for kdb backtrace, cpu 3

This error results in the following some time later on:
 kdba_release_init_slave_stack: INIT slave tripped on cpu 0 when not in 
 kdb,should never happen

The reason for the initial error is that kdba_mca_init() expects that 
the floating point registers were saved by SAL when in fact they were 
not.  The SAL spec states that it is not necessary to store them and, 
in the interests of NMRAM real estate, the HP rx7620 and rx8620 systems 
do not.

What would be the down-side of ignoring the valid.fr bit?  I notice that
cr and minstate bits seem to have been ignored in previous changes.  
Here is the code:

1782         if (!s ||
1783 #if 0
1784             /* Itanium Erratum 66:
1785              *  on some models CR is always reported invalid
1786              *  minstate being zero could be an inherited error
1787              */
1788             !s->valid.cr ||
1789             !s->valid.minstate ||
1790 #endif
1791             !s->valid.br ||
1792             !s->valid.ar ||
1793             !s->valid.rr ||
1794             !s->valid.fr) {                              <=
1795                 /* Use printk to get the text in dmesg */
1796                 printk("%s: not enough data in pal_min_state_area for kdb
backtrace, cpu %d\n",
1797                                 __FUNCTION__, smp_processor_id());
1798                 goto out;
1799         }

Does removing the !s->valid.fr check seem like the appropriate fix, or 
do you have another suggestion?

Thanks,

Alan Tyson, HP Services. 

