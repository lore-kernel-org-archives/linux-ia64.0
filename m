From: Jack Steiner <steiner@sgi.com>
Date: Mon, 29 Oct 2001 18:33:37 +0000
Subject: Re: [Linux-ia64] itc sync & clock_*
Message-Id: <marc-linux-ia64-105590698805409@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805400@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805400@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

I sent mail to Asit last week about this. Copy is attached:


>> Asit -
>> 
>> The SGI platforms do not have a synchronized FSB clock across all nodes.
>> The result of this is ar.itc on different cpus may drift. There is code in the kernel
>> that assumes that all nodes stay synchronized. This obviously doesn't work on
>> our platform. (I expect other platforms will have similar problems).
>> 
>> We send David mods to handle this but he felt (& I agree) that SAL
>> should pass a flag that indicates whether the clocks are synchronized.
>> Then, the kernel can enable/disable the code that assumes clocks are
>> synchronized based on this flag - not a platform #ifdef.
>> 
>> Do you agree with this approach??
>> 
>> What do we need to do to get this flag added to the SAL spec.
>> 
>> My suggestion is (include/asm-ia64/sal.h):
>> 
>>        #define IA64_SAL_PLATFORM_FEATURE_BUS_LOCK              (1 << 0)
>>        #define IA64_SAL_PLATFORM_FEATURE_IRQ_REDIR_HINT        (1 << 1)
>>        #define IA64_SAL_PLATFORM_FEATURE_IPI_REDIR_HINT        (1 << 2)
>>        #define IA64_SAL_PLATFORM_FEATURE_ITC_UNSYNCHRONIZED    (1 << 3)        <<<< NEW
>>
>>        typedef struct ia64_sal_desc_platform_feature {
>>                u8 type;
>>                u8 feature_mask;
>>                u8 reserved1[14];
>>        } ia64_sal_desc_platform_feature_t;
>>

> 
> On Mon, 29 Oct 2001, David Mosberger wrote:
> 
> > The first thing to do is to get this into the firmware.  Linux needs a
> > way to detect when the ITCs are not driven off the same clock (i.e.,
> > when there is a chance for the ITCs to drift).  There also needs to be
> > a way for detecting when the clock frequencies are different, but I
> > believe the info provided by PAL/SAL is sufficient (my only worry are
> > rounding errors...).
> 
> Ok, we'll work on getting this pushed back, so at least the kernel can
> figure out what to do.  Regarding glibc though: we really don't want to
> have a different version just for our systems, so I'd like to come up with
> a generic solution.  Maybe an ia64 specific clock driver that glibc could
> map in to read synchronized clock info?  Is there a platform independent
> way of doing this?  I'll poke around glibc some more to see if any of the
> other arches deal with tis problem, but I'm sure there are people that are
> already familiar with these sorts of issues that might be able to help
> out.  Anyone?
> 
> Thanks a lot,
> Jesse
> 
> 
> _______________________________________________
> Linux-IA64 mailing list
> Linux-IA64@linuxia64.org
> http://lists.linuxia64.org/lists/listinfo/linux-ia64
> 


-- 
Thanks

Jack Steiner    (651-683-5302)   (vnet 233-5302)      steiner@sgi.com


