From: Keith Owens <kaos@sgi.com>
Date: Fri, 08 Aug 2003 00:41:39 +0000
Subject: Re: [patch] 2.4.21-ia64-030702 arch/ia64/kernel/mca.c
Message-Id: <marc-linux-ia64-106030334825125@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105909779318784@msgid-missing>
In-Reply-To: <marc-linux-ia64-105909779318784@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, 7 Aug 2003 17:03:22 -0600, 
Bjorn Helgaas <bjorn.helgaas@hp.com> wrote:
>On Saturday 19 July 2003 12:25 am, Keith Owens wrote:
>> Patches to arch/ia64/kernel/mca.c against 2.4.21-ia64-030702.
>>
>> Generic:
>>   Issue a message to identify INIT/MCA records printed on the next boot.
>
>ia64_log_print() already prints a note on the next boot if the log
>contains saved records.  That note could be expanded, but the
>logic around the new return values seems too complicated to me.

ia64_mca_log_sal_error_record() returns 0 for no records and also for
success, making it impossible for the caller to determine if there were
any records.  ia64_mca_check_errors() only prints the message "The
above MCA error records were posted by SAL for a prior failure" if
there is at least one record at boot time, i.e. it needs the return
code from ia64_mca_log_sal_error_record() to distinguish between no
records and success.

>>   Enable console logging for INIT/MCA messages.
>
>I guess this refers to the SGI-specific addition to ia64_log_print().
>I'm hoping to decrease, not increase, the error record decoding
>code in the kernel.  Particularly for INIT, this is code that is
>(1) platform-specific, and (2) only used after a non-recoverable
>error.  It seems better to move such code to an off-line environment.

OK in the long run.  But until salinfo takes over as the official
method of handling log records, the mca.c code is still used.  These
small changes make the mca.c code more reliable.

>>   OEM data can be variable sized, do not use sizeof().
>
>I don't quite understand this one.  Don't these:
>
>> -				      (int)sizeof(sal_log_plat_specific_err_info_t) - 1,
>> +				      ((char*)psei->oem_data - (char*)psei),
>
>compute the same value?  I see that OEM data can be of variable
>size (and we use "u8 oem_data[1]" as a placeholder), but isn't this
>expression just computing the size of the fixed part of it?

platform_plat_specific_err_print() maps to ia64_log_prt_oem_data()
which expects a header length and a section length.
ia64_log_prt_oem_data() calculates the data length as the difference of
the first two parameters.

>>   Convert #ifdef CONFIG_SGI_SN2 to ia64_platform_is("sn2") to allow the
>>   building of generic kernels.
>
>I don't see any conversion -- just the addition of several ia64_platform_is()
>checks

The SGI ia64 tree had CONFIG_SGI_SN2 around some code.  That has to be
converted to a run time test to allow generic kernels to boot on SN2.
I incorrectly thought that the CONFIG_SGI_SN2 were in the base tree.

>which I object to, especially when they change the behavior of
>things that are not obviously platform-dependent.  For example, I think
>we should come up with a strategy for breaking SAL locks and clearing INIT
>logs that everybody can agree on.  Error handling is confusing enough
>without making it platform-dependent.

I agree, but so far only SN has any requirements for special processing
in mca.c.  Without a second platform, it is not clear what the coding
model should be.  I suggest you put in the sn2 changes and we review
them when another platform has similar requirements.

