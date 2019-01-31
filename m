From: Christophe Leroy <christophe.leroy@c-s.fr>
Date: Thu, 31 Jan 2019 07:07:29 +0000
Subject: Re: [PATCH v2 19/21] treewide: add checks for the return value of memblock_alloc*()
Message-Id: <d5e4ff5b-d33a-e641-8159-d4f83bc28d0b@c-s.fr>
List-Id: <linux-ia64.vger.kernel.org>
References: <1548057848-15136-1-git-send-email-rppt@linux.ibm.com>
 <1548057848-15136-20-git-send-email-rppt@linux.ibm.com>
 <b7c12014-14ae-2a38-900c-41fd145307bc@c-s.fr>
 <20190131064139.GB28876@rapoport-lnx>
 <8838f7ab-998b-6d78-02a8-a53f8a3619d9@c-s.fr>
In-Reply-To: <8838f7ab-998b-6d78-02a8-a53f8a3619d9@c-s.fr>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
To: Mike Rapoport <rppt@linux.ibm.com>
Cc: Rich Felker <dalias@libc.org>, linux-ia64@vger.kernel.org, Petr Mladek <pmladek@suse.com>, linux-sh@vger.kernel.org, Catalin Marinas <catalin.marinas@arm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, linux-kernel@vger.kernel.org, Max Filippov <jcmvbkbc@gmail.com>, Guo Ren <guoren@kernel.org>, sparclinux@vger.kernel.org, Christoph Hellwig <hch@lst.de>, linux-s390@vger.kernel.org, linux-c6x-dev@linux-c6x.org, Yoshinori Sato <ysato@users.sourceforge.jp>, Richard Weinberger <richard@nod.at>, x86@kernel.org, Russell King <linux@armlinux.org.uk>, kasan-dev@googlegroups.com, Geert Uytterhoeven <geert@linux-m68k.org>, Mark Salter <msalter@redhat.com>, Dennis Zhou <dennis@kernel.org>, Matt Turner <mattst88@gmail.com>, linux-snps-arc@lists.infradead.org, uclinux-h8-devel@lists.sourceforge.jp, devicetree@vger.kernel.org, Stephen Rothwell <sfr@canb.auug.org.au>, linux-xtensa@linux-xtensa.org, linux-um@lists.infradead.org, linux-m68k@lists.linux-m68k.org, Rob Herring <robh+dt@kernel.org>, Greentime Hu <green.hu@gmail.com>, xen-devel@lists.xenproject.org, Stafford Horne <shorne@gmail.com>, Guan Xuetao <gxt@pku.edu.cn>, linux-arm-kernel@lists.infradead.org, Michal Simek <monstr@monstr.eu>, Tony Luck <tony.luck@intel.com>, linux-mm@kvack.org, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, linux-usb@vger.kernel.org, linux-mips@vger.kernel.org, Paul Burton <paul.burton@mips.com>, Vineet Gupta <vgupta@synopsys.com>, linux-alpha@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, linuxppc-dev@lists.ozlabs.org, "David S. Miller" <davem@davemloft.net>, openrisc@lists.librecores.org



Le 31/01/2019 à 07:44, Christophe Leroy a écrit :
> 
> 
> Le 31/01/2019 à 07:41, Mike Rapoport a écrit :
>> On Thu, Jan 31, 2019 at 07:07:46AM +0100, Christophe Leroy wrote:
>>>
>>>
>>> Le 21/01/2019 à 09:04, Mike Rapoport a écrit :
>>>> Add check for the return value of memblock_alloc*() functions and call
>>>> panic() in case of error.
>>>> The panic message repeats the one used by panicing memblock 
>>>> allocators with
>>>> adjustment of parameters to include only relevant ones.
>>>>
>>>> The replacement was mostly automated with semantic patches like the one
>>>> below with manual massaging of format strings.
>>>>
>>>> @@
>>>> expression ptr, size, align;
>>>> @@
>>>> ptr = memblock_alloc(size, align);
>>>> + if (!ptr)
>>>> +     panic("%s: Failed to allocate %lu bytes align=0x%lx\n", __func__,
>>>> size, align);
>>>>
>>>> Signed-off-by: Mike Rapoport <rppt@linux.ibm.com>
>>>> Reviewed-by: Guo Ren <ren_guo@c-sky.com>             # c-sky
>>>> Acked-by: Paul Burton <paul.burton@mips.com>         # MIPS
>>>> Acked-by: Heiko Carstens <heiko.carstens@de.ibm.com> # s390
>>>> Reviewed-by: Juergen Gross <jgross@suse.com>         # Xen
>>>> ---
>>>
>>> [...]
>>>
>>>> diff --git a/mm/sparse.c b/mm/sparse.c
>>>> index 7ea5dc6..ad94242 100644
>>>> --- a/mm/sparse.c
>>>> +++ b/mm/sparse.c
>>>
>>> [...]
>>>
>>>> @@ -425,6 +436,10 @@ static void __init sparse_buffer_init(unsigned 
>>>> long size, int nid)
>>>>           memblock_alloc_try_nid_raw(size, PAGE_SIZE,
>>>>                           __pa(MAX_DMA_ADDRESS),
>>>>                           MEMBLOCK_ALLOC_ACCESSIBLE, nid);
>>>> +    if (!sparsemap_buf)
>>>> +        panic("%s: Failed to allocate %lu bytes align=0x%lx nid=%d 
>>>> from=%lx\n",
>>>> +              __func__, size, PAGE_SIZE, nid, __pa(MAX_DMA_ADDRESS));
>>>> +
>>>
>>> memblock_alloc_try_nid_raw() does not panic (help explicitly says: 
>>> Does not
>>> zero allocated memory, does not panic if request cannot be satisfied.).
>>
>> "Does not panic" does not mean it always succeeds.
> 
> I agree, but at least here you are changing the behaviour by making it 
> panic explicitly. Are we sure there are not cases where the system could 
> just continue functionning ? Maybe a WARN_ON() would be enough there ?

Looking more in details, it looks like everything is done to live with 
sparsemap_buf NULL, all functions using it check it so having it NULL 
shouldn't imply a panic I believe, see code below.

static void *sparsemap_buf __meminitdata;
static void *sparsemap_buf_end __meminitdata;

static void __init sparse_buffer_init(unsigned long size, int nid)
{
	WARN_ON(sparsemap_buf);	/* forgot to call sparse_buffer_fini()? */
	sparsemap_buf 		memblock_alloc_try_nid_raw(size, PAGE_SIZE,
						__pa(MAX_DMA_ADDRESS),
						MEMBLOCK_ALLOC_ACCESSIBLE, nid);
	sparsemap_buf_end = sparsemap_buf + size;
}

static void __init sparse_buffer_fini(void)
{
	unsigned long size = sparsemap_buf_end - sparsemap_buf;

	if (sparsemap_buf && size > 0)
		memblock_free_early(__pa(sparsemap_buf), size);
	sparsemap_buf = NULL;
}

void * __meminit sparse_buffer_alloc(unsigned long size)
{
	void *ptr = NULL;

	if (sparsemap_buf) {
		ptr = PTR_ALIGN(sparsemap_buf, size);
		if (ptr + size > sparsemap_buf_end)
			ptr = NULL;
		else
			sparsemap_buf = ptr + size;
	}
	return ptr;
}


Christophe
