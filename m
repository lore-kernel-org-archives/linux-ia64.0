From: Takao Indoh <indou.takao@jp.fujitsu.com>
Date: Thu, 07 Sep 2006 14:48:51 +0000
Subject: RE: [Fastboot] [PATCH]IA64 kexec/kdump patch for INIT
Message-Id: <94C6D28CBC0DB1indou.takao@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <82C6D21B8B7A9Cindou.takao@jp.fujitsu.com>
In-Reply-To: <82C6D21B8B7A9Cindou.takao@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, 7 Sep 2006 21:01:17 +0800, "Yu, Luming" wrote:

>>>Did  saved Os gp in SAL OS state  somehow get overridden before 
>>>ia64_set_kernel_registers prior to invocation of ia64_init_handler?
>>>
>>>I assume the following code (in ia64_set_kernel_registers ) 
>>should restore 
>>>correct GP value.
>>>
>>>ia64_set_kernel_registers:
>>>	...
>>>        ;;
>>>        ld8 r1=[temp4]          // OS GP from SAL OS state
>>
>>Yes, but this gp value is physical address.
>>In the next line, gp is changed to virtual address.
>>
>>DATA_PA_TO_VA(r1,temp1)
>>
>>This macro just sets region7 bit, so gp value becomes region7 address.
>
>Ok, could you please confirm what is the value of r1 before
>DATA_PA_TO_VA(r1, temp1)?
>I guess we need to set r1 = __gp in ia64_set_kernel_registers.
>If not,  this is a bug.  Am I right?

In the ia64_mca_init, the value of ia64_tpa(ia64_getreg(_IA64_REG_GP)
is registered as gp value. When cpu comes into the above code, r1 is set
to this value, I think. Therefore, r1 has physical address of __gp
before DATA_PA_TO_VA(r1, temp1). How do you think?

I think you are right, I also think r1 has to be set to __gp before 
calling ia64_init_handler.

Regards,
Takao Indoh

