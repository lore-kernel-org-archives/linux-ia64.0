From: Takao Indoh <indou.takao@jp.fujitsu.com>
Date: Thu, 07 Sep 2006 09:17:10 +0000
Subject: Re: [Fastboot] [PATCH]IA64 kexec/kdump patch for INIT
Message-Id: <8BC6D25E65EB3Eindou.takao@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <82C6D21B8B7A9Cindou.takao@jp.fujitsu.com>
In-Reply-To: <82C6D21B8B7A9Cindou.takao@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, 7 Sep 2006 16:48:19 +0800, Yu Luming wrote:

>> I agree. I'm also happy if kdb and kdump share the code.
>> I'll check kdb code.
>>
>> >>+		/* change region of gp to region5 */
>> >>+		asm volatile ("movl gp=__gp"::: "memory");
>> >
>> >Why?  gp is already pointing at the kernel code before we enter
>> >ia64_init_handler().
>>
>> The purpose of this code is just changing region of gp from region7 to
>> region5. For example, if gp is e000000004ace170, I want to change gp to
>> a000000104ace170, but I couldn't find good method. Is there good method
>> to change region?
>>
>Did  saved Os gp in SAL OS state  somehow get overridden before 
>ia64_set_kernel_registers prior to invocation of ia64_init_handler?
>
>I assume the following code (in ia64_set_kernel_registers ) should restore 
>correct GP value.
>
>ia64_set_kernel_registers:
>	...
>        ;;
>        ld8 r1=[temp4]          // OS GP from SAL OS state

Yes, but this gp value is physical address.
In the next line, gp is changed to virtual address.

DATA_PA_TO_VA(r1,temp1)

This macro just sets region7 bit, so gp value becomes region7 address.

Regards,
Takao Indoh


