From: Keith Owens <kaos@sgi.com>
Date: Thu, 04 Dec 2003 02:05:18 +0000
Subject: Re: [patch] 2.6.0-test9 pal/sal/salinfo/mca
Message-Id: <marc-linux-ia64-107050354326437@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106978478405713@msgid-missing>
In-Reply-To: <marc-linux-ia64-106978478405713@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On 03 Dec 2003 17:38:19 -0800, 
Ben Woodard <woodard@redhat.com> wrote:
>On Tue, 2003-11-25 at 00:37, Keith Owens wrote:
>> Forward port the recent changes to pal.h, sal.h, mca.h, salinfo.c and
>> mca.c from 2.4.23-rc2 to 2.6.0-test9.
>> 
>> This converts 2.6 to use salinfo instead of printing CMC/CPE/MCA/INIT
>> records in the kernel.  It makes the two kernel versions as close
>> together as possible.
>
>I'd like to inquire a bit more into the state of MCA in 2.4 and 2.6. We
>are assembling a 1000 node ia64 cluster out of intel Tiger 4 servers and
>we want to make sure that MCA works well enough that we can at least get
>a good count of the ECC SBE's and panic if we get a MBE. 
>
>We are currently basing our kernel off of the Red Hat Enterprise Linux 3
>kernel and we discovered that the implementation of MCA included with it
>does not work for us. The most obvious problem is that it never calls
>ia64_sal_clear_state_info after fetching a SAL record. Thus the CPE
>reasserts itself and the machine effectively locks up infinitely
>printing out the same CPE to the console.

2.4.23 ia64 BK tree has these lines in ia64_mca_log_sal_error_record().

        salinfo_log_wakeup(sal_info_type, buffer, size);
        platform_err = ia64_log_print(sal_info_type, (prfunc_t)printk);
        /* Clear logs from corrected errors in case there's no user-level logger */
        if (sal_info_type = SAL_INFO_TYPE_CPE || sal_info_type = SAL_INFO_TYPE_CMC)
                ia64_sal_clear_state_info(sal_info_type);

so you should be clearing CPE records immediately.  AS 3.0 is probably
out of date in its MCA handling.

>So what we are trying to do is improve the state of the MCA handling in
>our kernel. I managed a backport of the MCA code from 2.6.0-test9 to 2.4
>and it works much better. However, there are a couple of problems with
>it that could probably be sorted out by someone who understands the code
>better. Keith your message sort of hints that the possibility that the
>2.4 kernel's MCA code is further advanced than the 2.6 code.

With my 2.6 patch of 2003-11-25, 2.4 and 2.6 MCA handling is the same,
and it works for CPE.  Grab these files from ia64 2.4 BK and merge them
with the AS 3.0 files, if there is ay doubt, use the ia64 2.4 BK
version.

include/asm-ia64/sal.h
include/asm-ia64/pal.h
include/asm-ia64/mca.h
arch/ia64/Kconfig
arch/ia64/kernel/Makefile
arch/ia64/kernel/salinfo.c
arch/ia64/kernel/mca.c

