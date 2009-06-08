From: Amerigo Wang <amwang@redhat.com>
Date: Mon, 08 Jun 2009 01:28:59 +0000
Subject: Re: [Patch 4/5] module: trim exception table in module_free()
Message-Id: <4A2C695B.2060505@redhat.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20090604014813.6332.18486.sendpatchset@localhost.localdomain> <200906041800.54696.rusty@rustcorp.com.au> <4A278C62.8000801@redhat.com> <200906060038.03089.rusty@rustcorp.com.au>
In-Reply-To: <200906060038.03089.rusty@rustcorp.com.au>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Rusty Russell <rusty@rustcorp.com.au>
Cc: linux-kernel@vger.kernel.org, jdike@addtoit.com, hch@infradead.org, mingo@elte.hu, akpm@linux-foundation.org, David Miller <davem@davemloft.net>, sparclinux@vger.kernel.org, linux-alpha@vger.kernel.org, linux-ia64@vger.kernel.org

Rusty Russell wrote:
> On Thu, 4 Jun 2009 06:27:06 pm Amerigo Wang wrote:
>   
>> Rusty Russell wrote:
>>     
>>> I've taken this one to make it more generic.  I'll leave the x86
>>> maintainers to apply the rest.
>>>       
>> Thank you. But this one depends on the previous, I don't think you can
>> apply this without the previous ones.
>>     
>
> Here's what I ended up with: I need to rig up a test and make sure it goes to
> all the maintainers and linux-next.
>
> Subject: module: trim exception table on init free.
>
> It's theoretically possible that there are exception table entries
> which point into the (freed) init text of modules.  These could cause
> future problems if other modules get loaded into that memory and cause
> an exception as we'd see the wrong fixup.
>
> Amerigo fixed this long-standing FIXME in the x86 version, but this
> patch is more general.
>
> This implements trim_init_extable(); most archs are simple since they
> use the standard lib/extable.c sort code.  Alpha and IA64 use relative
> addresses in their fixups, so thier trimming is a slight variation.
>
> Sparc32 is unique; it doesn't seem to define ARCH_HAS_SORT_EXTABLE,
> yet it defines its own sort_extable() which overrides the one in lib.
> It doesn't sort, so we have to mark deleted entries instead of
> actually trimming them.
>
> Inspired-by: Amerigo Wang <amwang@redhat.com>
> Signed-off-by: Rusty Russell <rusty@rustcorp.com.au>
>   

Very nice!
The generic part of this patch looks good for me, of course. :)

Thank you, Rusty!


