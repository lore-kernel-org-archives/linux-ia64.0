From: Jan Schreckenbach <Jan.Schreckenbach@sap.com>
Date: Thu, 21 Feb 2002 19:04:36 +0000
Subject: Re: [Linux-ia64] latest working kernel
Message-Id: <marc-linux-ia64-105590701905162@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701905159@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701905159@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi,

works for me on SuSE SLES7:

ls3125:~# cat /proc/version
Linux version 2.4.17 (root@ls3125) (gcc version 3.0.3) #2 SMP Thu Feb 21 19:06:16 CET 2002
ls3125:~# ld -V
GNU ld version 2.11.90.0.8 (with BFD 2.11.90.0.8)
   Supported emulations:
    elf64_ia64
ls3125:~#

Thx!

cu,
  Jan

Hall, Jenna S wrote:
> Any kernel should run as long as the FW83 stability patch is applied.  See
> attached.
> 
> Jenna
> 
> 
> 
> -----Original Message-----
> From: Jan Schreckenbach [mailto:Jan.Schreckenbach@sap.com]
> Sent: Thursday, February 21, 2002 9:28 AM
> To: linux-ia64
> Subject: [Linux-ia64] latest working kernel
> 
> Hello,
> 
> what is the latest kernel running on a C0-step
> Lion with FW 83B?
> 
> Thx!
> 
> cu,
>    Jan
> 
> --
> _______________________________________________________________________
> 
> THE BEST RUN E-BUSINESSES RUN SAP
> _______________________________________________________________________
> 
> Jan Schreckenbach                      email: Jan.Schreckenbach@sap.com
> SAP AG Walldorf/Baden, Germany         Phone: +49 6227  7-47474
> LinuxLab                               Fax  : +49 6227 78-31414
> 
> SAP LinuxLab support address: linux@sap.com
> 
> 
> _______________________________________________
> Linux-IA64 mailing list
> Linux-IA64@linuxia64.org
> http://lists.linuxia64.org/lists/listinfo/linux-ia64
> 
> 
> 
> ------------------------------------------------------------------------
> 
> From: Mallick, Asit K [asit.k.mallick@intel.com]
> Sent: Thursday, January 24, 2002 11:47 AM
> To: linux-ia64@linuxia64.org
> Subject: [Linux-ia64] Patch to fix latest kernels issue with FW83
> 
> We have root caused the stability problem with latest kernels and FW83 (LION
> platform). The following patch (based on 2.4.17) fixes the problem. Please
> let me know if you still see a problem after applying this patch.
> 
> Thanks,
> Asit
>  <<patch.FW83>> 
> --- /home1/src/linux/include/asm-ia64/spinlock.h    Wed Jan  9 19:25:05 2002
> +++ linux/include/asm-ia64/spinlock.h   Wed Jan 23 15:52:45 2002
> @@ -84,7 +84,7 @@
>     "mov r29 = 1\n"                     \
>     ";;\n"                          \
>     "1:\n"                          \
> -   "ld4.bias r2 = [%0]\n"                  \
> +   "ld4 r2 = [%0]\n"                   \
>     ";;\n"                          \
>     "cmp4.eq p0,p7 = r0,r2\n"               \
>     "(p7) br.cond.spnt.few 1b \n"               \
> 
> 


-- 
--
_______________________________________________________________________

THE BEST RUN E-BUSINESSES RUN SAP
_______________________________________________________________________

Jan Schreckenbach                      email: Jan.Schreckenbach@sap.com
SAP AG Walldorf/Baden, Germany         Phone: +49 6227  7-47474
LinuxLab                               Fax  : +49 6227 78-31414

SAP LinuxLab support address: linux@sap.com


