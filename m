From: Jes Sorensen <jes@sgi.com>
Date: Wed, 20 Dec 2006 09:48:54 +0000
Subject: Re: [patch 3/3] IA64: virt_to_page() can be called with NULL arg
Message-Id: <45890706.7070002@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200612192104.kBJL4iBg010376@shell0.pdx.osdl.net>
In-Reply-To: <200612192104.kBJL4iBg010376@shell0.pdx.osdl.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Kirill Korotaev wrote:
>>>>>>> "akpm" = akpm  <akpm@osdl.org> writes:
>>
>> akpm> From: Kirill Korotaev <dev@openvz.org> It does not return NULL
>> akpm> when arg is NULL.
>>
>> Shouldn't the real fix be to track down who calls virt_to_page() with
>> a NULL pointer? IMHO it is bogus to do so.
> what do you propose? to insert BUG_ON(!kaddr) into virt_to_page()?
> in this case caller in question should be still fixed.

If you hit this, yes I'd insert the BUG_ON in your test kernel and fix
the code. Maybe add the BUG_ON in upstream for CONFIG_DEBUG or
something.

Which callers did you see cause this? If it was a common problem I would
expect a lot of data corruption or crashes on ia64 systems which I
haven't heard of.

Cheers,
Jes
