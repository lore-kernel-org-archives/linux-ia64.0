From: Kamalesh Babulal <kamalesh@linux.vnet.ibm.com>
Date: Wed, 11 Jun 2008 16:58:26 +0000
Subject: Re: [BUILD-FAILURE] linux-next: Tree for June 11 - on ia64
Message-Id: <48500162.3060604@linux.vnet.ibm.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20080611193840.08a35b14.sfr@canb.auug.org.au> <484FE1EE.9020201@linux.vnet.ibm.com> <20080611145057.GA10487@uranus.ravnborg.org>
In-Reply-To: <20080611145057.GA10487@uranus.ravnborg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Sam Ravnborg <sam@ravnborg.org>
Cc: Stephen Rothwell <sfr@canb.auug.org.au>, linux-next@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, linux-ia64@vger.kernel.org, Andy Whitcroft <apw@shadowen.org>

Sam Ravnborg wrote:
> On Wed, Jun 11, 2008 at 08:02:14PM +0530, Kamalesh Babulal wrote:
>> Hi Stephen,
>>
>> The next-20080611 kernel build fails on ia64 machine
>>
>>   AR      arch/ia64/lib/lib.a
>>   LD      vmlinux.o
>>   MODPOST vmlinux.o
>>   GEN     .version
>>   CHK     include/linux/compile.h
>>   UPD     include/linux/compile.h
>>   CC      init/version.o
>>   LD      init/built-in.o
>>   LD      .tmp_vmlinux
>>   LD      vmlinux
>> ld: .tmp_kallsyms.o: linking constant-gp files with non-constant-gp files
>> ld: failed to merge target specific data of file .tmp_kallsyms.o
>> make: *** [vmlinux] Error 1
> 
> A kbuild bug..
> We do a local build of .tmp_kallsyms.o and we do not pass -mconstant-gp
> 
> Can you please try if the following patch fixes it.
> 
> 	Sam

Hi Sam,

Thanks, the patch fixes the build failure.

Tested-by: Kamalesh Babulal <kamalesh@linux.vnet.ibm.com>
> 
> diff --git a/scripts/link-vmlinux.sh b/scripts/link-vmlinux.sh
> index b9ecff5..b335700 100644
> --- a/scripts/link-vmlinux.sh
> +++ b/scripts/link-vmlinux.sh
> @@ -128,7 +128,7 @@ if [ "${CONFIG_KALLSYMS}" = "y" ]; then
> 
>  	# Do an extra pass to link in kallsyms data
>  	${NM} -n .tmp_vmlinux | scripts/kallsyms > .tmp_kallsyms.S
> -        ${CC} ${KBUILD_AFLAGS} ${KBUILD_CPPFLAGS} -c -o .tmp_kallsyms.o \
> +        ${CC} ${KBUILD_AFLAGS} ${AFLAGS_KERNEL} ${KBUILD_CPPFLAGS} -c -o .tmp_kallsyms.o \
>  	      .tmp_kallsyms.S
>          # link in kalll symbols
>  	tell LD vmlinux
> --

-- 
Thanks & Regards,
Kamalesh Babulal,
Linux Technology Center,
IBM, ISTL.
