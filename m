From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Date: Wed, 29 Mar 2006 06:50:41 +0000
Subject: RE: Fix unlock_buffer() to work the same way as bit_unlock()
Message-Id: <200603290649.k2T6ntg03758@unix-os.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
In-Reply-To: <4428EF8B.7040202@yahoo.com.au>
References: <Pine.LNX.4.64.0603271953150.7469@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.64.0603271953150.7469@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: 'Nick Piggin' <nickpiggin@yahoo.com.au>, Christoph Lameter <clameter@sgi.com>
Cc: akpm@osdl.org, Zoltan.Menyhart@free.fr, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org

Nick Piggin wrote on Tuesday, March 28, 2006 12:11 AM
> OK, that's fair enough and I guess you do need a barrier there.
> However, should the mb__after barrier still remain? The comment
> in wake_up_bit suggests yes, and there is similar code in
> unlock_page.

Question on unlock_page:

void fastcall unlock_page(struct page *page)
{
        smp_mb__before_clear_bit();
        if (!TestClearPageLocked(page))
                BUG();
        smp_mb__after_clear_bit();
        wake_up_page(page, PG_locked);
}

Assuming test_and_clear_bit() on all arch does what the API is
called for with full memory fence around the atomic op, why do
you need smp_mb__before_clear_bit and smp_mb__after_clear_bit?
Aren't they redundant?

- Ken
