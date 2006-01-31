From: Jes Sorensen <jes@trained-monkey.org>
Date: Tue, 31 Jan 2006 10:57:05 +0000
Subject: Re: [patch 5/5] fix sn rw_mmr.h to use intrinsic
Message-Id: <yq04q3kr7ge.fsf@jaguar.mkp.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <200601270137.k0R1big21236@unix-os.sc.intel.com>
In-Reply-To: <200601270137.k0R1big21236@unix-os.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> "Ken" = Chen, Kenneth W <kenneth.w.chen@intel.com> writes:

Ken> Jes Sorensen wrote on Friday, January 27, 2006 1:57 AM
>>  I'll have to test this. However it really doesn't matter much as
>> we won't be building the SN kernel with ICC.

Ken> When I build a generic kernel, all sn code are pulled in and need
Ken> to be compiled.  It would be nice to have sn portion of kernel
Ken> code free of asm statement in the source. I heard that gcc is
Ken> also going in the direction of implementing intrinsic in the long
Ken> term.  Or do we have an option of CONFIG_NON_SGI?  I can cook up
Ken> something if this is really what people Want (I suspect not).

Ken,

Speaking solely on my own behalf, and not that of my employer here.

I have to say that I have always found it very discouraging how the
kernel had this mess added which is badly obfuscating the code solely
to support one vendor's broken compiler.

The real solution to this problem would be for Intel's compiler people
to fix the brokenness of ICC instead of adding any more of this
obfuscation to the kernel ;-(

Regards,
Jes
