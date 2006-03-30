From: Nick Piggin <nickpiggin@yahoo.com.au>
Date: Thu, 30 Mar 2006 01:36:25 +0000
Subject: Re: Fix unlock_buffer() to work the same way as bit_unlock()
Message-Id: <442B3619.8070502@yahoo.com.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <200603290649.k2T6ntg03758@unix-os.sc.intel.com>
In-Reply-To: <200603290649.k2T6ntg03758@unix-os.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Cc: Christoph Lameter <clameter@sgi.com>, akpm@osdl.org, Zoltan.Menyhart@free.fr, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org

Chen, Kenneth W wrote:

>Nick Piggin wrote on Tuesday, March 28, 2006 12:11 AM
>
>>OK, that's fair enough and I guess you do need a barrier there.
>>However, should the mb__after barrier still remain? The comment
>>in wake_up_bit suggests yes, and there is similar code in
>>unlock_page.
>>
>
>Question on unlock_page:
>
>void fastcall unlock_page(struct page *page)
>{
>        smp_mb__before_clear_bit();
>        if (!TestClearPageLocked(page))
>                BUG();
>        smp_mb__after_clear_bit();
>        wake_up_page(page, PG_locked);
>}
>
>Assuming test_and_clear_bit() on all arch does what the API is
>called for with full memory fence around the atomic op, why do
>you need smp_mb__before_clear_bit and smp_mb__after_clear_bit?
>Aren't they redundant?
>
>

Yep. I pointed this out earlier.

I'd say it may have initially just been a ClearPageLocked, and
was changed for debugging reasons.

We could instead change it to

BUG_ON(!PageLocked(page);
ClearPageLocked(page); /* this does clear_bit_for_unlock */
smp_mb__after_clear_bit_unlock();
wake_up_page

--

Send instant messages to your online friends http://au.messenger.yahoo.com 
