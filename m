From: Keith Owens <kaos@sgi.com>
Date: Fri, 15 Sep 2006 05:02:33 +0000
Subject: Re: [PATCH]Make gp value point to Region 5 in mca handler
Message-Id: <31039.1158296553@kao2.melbourne.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1158123325.2591.46.camel@linux-znh>
In-Reply-To: <1158123325.2591.46.camel@linux-znh>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Zou Nan hai (on 14 Sep 2006 08:25:15 +0800) wrote:
>On Wed, 2006-09-13 at 17:54, Keith Owens wrote:
>> Zou Nan hai (on 13 Sep 2006 12:55:25 +0800) wrote:
>> >The patch set gp register to kernel gp of region 5 at entry of MCA
>> >dispatch.
>> >
>> >Signed-off-by: Zou Nan hai <nanhai.zou@intel.com>
>> 
>> The idea is right, but there is no need to pass __gp to
>> VIRTUAL_MODE_ENTER.  There will never be a case of VIRTUAL_MODE_ENTER
>> followed by entry to a module, so just hard code 'movl r1 = __gp' into
>> VIRTUAL_MODE_ENTER and drop it from the parameter list.
>
> OK, I felt a little weird to put hard code in a macro.., but I think it
>does not matter much since the macro is only used 2 times.
>
> the updated patch 
>
> Signed-off-by: Zou Nan hai <nanhai.zou@intel.com>

Acked-by: Keith Owens <kaos@sgi.com>

BTW, your patch deleted the only use of IA64_SAL_OS_STATE_OS_GP_OFFSET
so that field can also be deleted from arch/ia64/kernel/asm-offsets.c.

