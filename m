From: Nick Piggin <nickpiggin@yahoo.com.au>
Date: Wed, 29 Mar 2006 02:35:40 +0000
Subject: Re: Fix unlock_buffer() to work the same way as bit_unlock()
Message-Id: <4429F27C.6020404@yahoo.com.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <200603281853.k2SIrGg28290@unix-os.sc.intel.com> <4429ADBC.50507@free.fr> <Pine.LNX.4.64.0603281537500.15037@schroedinger.engr.sgi.com> <4429CFCA.7010201@yahoo.com.au> <Pine.LNX.4.64.0603281822570.18374@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.64.0603281822570.18374@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Christoph Lameter <clameter@sgi.com>
Cc: Zoltan Menyhart <Zoltan.Menyhart@free.fr>, "Chen, Kenneth W" <kenneth.w.chen@intel.com>, akpm@osdl.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org

Christoph Lameter wrote:

>On Wed, 29 Mar 2006, Nick Piggin wrote:
>
>
>>However, I think it might be reaonsable to use bit lock operations for
>>in places like page lock and buffer lock (ie. with acquire and relese
>>semantics). It improves ia64 without harming other architectures, and
>>also makes the code more expressive.
>>
>
>How would be express the acquire and release semantics?
>

Hmm, not sure. Maybe a few new bitops with _lock / _unlock postfixes?
For page lock and buffer lock we'd just need test_and_set_bit_lock,
clear_bit_unlock, smp_mb__after_clear_bit_unlock.

I don't know, _for_lock might be a better name. But it's getting long.

--

Send instant messages to your online friends http://au.messenger.yahoo.com 
