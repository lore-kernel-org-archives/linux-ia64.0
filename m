From: Keith Owens <kaos@sgi.com>
Date: Sun, 10 Aug 2003 05:08:12 +0000
Subject: Re: [patch] 2.4.21-ia64-030702 arch/ia64/kernel/mca.c
Message-Id: <marc-linux-ia64-106049225722614@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105909779318784@msgid-missing>
In-Reply-To: <marc-linux-ia64-105909779318784@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Fri, 8 Aug 2003 11:15:30 -0600,
Bjorn Helgaas <bjorn.helgaas@hp.com> wrote:
>On Thursday 07 August 2003 6:41 pm, Keith Owens wrote:
>I don't understand the changes well enough to be convinced that
>they're SGI-specific.  For instance:
>
>> +#ifdef CONFIG_SMP
>> +    if (ia64_platform_is("sn2") && sal_lock.lock) {
>> +            udelay(500000);
>> +            sal_lock.lock = 0;
>> +    }
>> +#endif
>
>ia64_sal_get_state_info() uses SAL_CALL(), which acquires sal_lock.
>So it seems that every platform would deadlock if we MCA in the
>middle of a previous SAL call.  Or is there something peculiar
>about SGI firmware?

SAL spec 9.1.

  * Some SAL procedures are primarily intended for use during OS
    initialization and designed to be called on one processor. These are
    not required to be re-entrant. Some SAL procedures are required to be
    called on multiple processors simultaneously. These are required to
    be MP-safe but need not be re-entrant. Some SAL procedures may be
    re-invoked on the same processor, e.g. the invocation of the
    SAL_GET_STATE_INFO procedure for a CPE event may be interrupted by
    the invocation of the same procedure for an MCA event on the same
    processor.  Such procedures need to be re-entrant as well as MP-safe.
    These requirements are specified in Table 9.3. For the procedures
    that are not re-entrant, the operating system is required to enforce
    single threaded access.


Table 9-2. SAL Procedures

                         Function ID                                          Re-entrancy
  Procedure                                    Description
                           (hex)                                              Requirement
  SAL_SET_VECTORS          0x01000000   Register software code locations      None
                                        with SAL.
  SAL_GET_STATE_INFO       0x01000001   Return Machine State information      Yes
                                        obtained by SAL.
  SAL_GET_STATE_INFO_SIZE  0x01000002   Obtain size of Machine State          Yes
                                        information.
  SAL_CLEAR_STATE_INFO     0x01000003   Clear Machine State information.      Yes
  SAL_MC_RENDEZ            0x01000004   Cause the processor to go into a      MP-safe
                                        spin loop within SAL.
  SAL_MC_SET_PARAMS        0x01000005   Register the machine check interface  None
                                        layer with SAL.
  SAL_REGISTER_PHYSICAL_   0x01000006   Register the physical addresses of    None
  ADDR                                  locations needed by SAL.
  SAL_CACHE_FLUSH          0x01000008   Flush the instruction or data caches. MP-safe
  SAL_CACHE_INIT           0x01000009   Initialize the instruction and data   MP-safe
                                        caches.
  SAL_PCI_CONFIG_READ      0x01000010   Read from the PCI configuration       Yes
                                        space.
  SAL_PCI_CONFIG_WRITE     0x01000011   Write to the PCI configuration space. Yes
  SAL_FREQ_BASE            0x01000012   Return the base frequency of the      MP-safe
                                        platform.
  SAL_UPDATE_PAL           0x01000020   Update the contents of firmware       None
  blocks.


The current kernel code does not conform to those specifications.
SAL_GET_STATE_INFO_SIZE is supposed to be reentrant safe so it does not
deadlock, but the Linux code uses SAL_CALL() with a spinlock that will
hang for SAL_GET_STATE_INFO_SIZE during an existing SAL event.  I have
hit this case.

The real fix is to change the non-conforming functions in sal.h to use
SAL_CALL_NOLOCK.  But is it safe to do so, can all the platforms handle
reentrant SAL calls?

I know that SGI SAL code is reentrant safe so I break any existing SAL
lock, but only on SN2.  If the other platforms say that they are
reentrant safe and the locking in sal.h is fixed then this sn2 specific
patch is not required.  Until then, we need it in the kernel.


>> +    if (ia64_platform_is("sn2")) {
>> +            /* SN saves logs until next boot */
>> +            ;
>> +    } else {
>> +            /* Clear the INIT SAL logs now that they have been saved in the OS buffer */
>> +            ia64_sal_clear_state_info(SAL_INFO_TYPE_INIT);
>> +    }
>
>You added back ia64_sal_clear_state_info() for all non-SGI platforms,
>which I don't think we want.

Merge hangover from 2.4.20.  Delete this patch hunk.

>> @@ -2076,6 +2141,11 @@ ia64_log_proc_dev_err_info_print (sal_lo
>> +            if (ia64_platform_is("sn2")) {
>> +                    platform_plat_specific_err_print((int)slpi->header.len,
>> +                          0, (void*)slpi, prfunc);
>> +                    return;
>> +            }
>
>> @@ -2301,7 +2371,13 @@ ia64_log_print(int sal_info_type, prfunc
>> -            prfunc("+MCA INIT ERROR LOG (UNIMPLEMENTED)\n");
>> +            if (ia64_platform_is("sn2")) {
>> +                    prfunc("+BEGIN HARDWARE ERROR STATE AT INIT\n");
>> +                    platform_err = ia64_log_platform_info_print(IA64_LOG_CURR_BUFFER(sal_info_type), prfunc);
>> +                    prfunc("+END HARDWARE ERROR STATE AT INIT\n");
>> +            } else {
>> +                    prfunc("+MCA INIT ERROR LOG (UNIMPLEMENTED)\n");
>> +            }
>
>Is there any reason not to do these on all platforms?  The
>"platform_plat_specific_err_print" looks a lot like a platform vector
>anyway, so I don't see the point of another test.

I inherited these so am not sure why they were SN2 specific.  There is
no obvious reason why they should not be done for all platforms.

