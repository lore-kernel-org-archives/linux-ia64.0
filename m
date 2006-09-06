From: Takao Indoh <indou.takao@soft.fujitsu.com>
Date: Wed, 06 Sep 2006 09:22:45 +0000
Subject: Re: [PATCH]IA64 kexec/kdump patch for INIT
Message-Id: <81C6D19602F2D5indou.takao@soft.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <75C6D0E56B35AEindou.takao@jp.fujitsu.com>
In-Reply-To: <75C6D0E56B35AEindou.takao@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, 06 Sep 2006 18:06:53 +0900, Takao Indoh wrote:

>>>+		/* change region of gp to region5 */
>>>+		asm volatile ("movl gp=__gp"::: "memory");
>>
>>Why?  gp is already pointing at the kernel code before we enter
>>ia64_init_handler().
>
>The purpose of this code is just changing region of gp from region7 to 
>region5. For example, if gp is e000000004ace170, I want to change gp to
                                ~~~~~~~~~~~~~~~~e000000000ace170
Sorry, I mistook address...


Regards,
Takao Indoh


