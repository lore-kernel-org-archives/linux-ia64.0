From: "Jan Beulich" <jbeulich@novell.com>
Date: Tue, 19 Dec 2006 13:26:47 +0000
Subject: Re: [discuss] swiotlb_sync_sg() issue?
Message-Id: <4587F6A7.76E4.0078.0@novell.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <4587D6D3.76E4.0078.0@novell.com>
In-Reply-To: <4587D6D3.76E4.0078.0@novell.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>> "Jan Beulich" <jbeulich@novell.com> 19.12.06 12:10 >>>
>Due to its apparent obviousness, I'm afraid I'm missing something, but isn't it
>incorrect that lib/swiotlb.c:swiotlb_sync_sg() calls sync_single() with
>sg->dma_address simply cast to void* rather than going through phys_to_virt()?
>
>Also, for ia64, isn't mark_clean() violating its own comment, i.e. to mark only
>*complete* pages? And then, for completeness, isn't swiotlb_sync_sg() missing
>the call to mark_clean()?

Okay, I see I mis-read mark_clean(), it's not violating what it claims to do. But
the other two questions remain.

Thanks, Jan
