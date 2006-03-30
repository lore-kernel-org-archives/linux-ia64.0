From: Nick Piggin <nickpiggin@yahoo.com.au>
Date: Thu, 30 Mar 2006 01:56:57 +0000
Subject: Re: Fix unlock_buffer() to work the same way as bit_unlock()
Message-Id: <442B3AE9.7090102@yahoo.com.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <200603290139.k2T1d1g00702@unix-os.sc.intel.com> <442A7AA6.7080206@bull.net>
In-Reply-To: <442A7AA6.7080206@bull.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Zoltan Menyhart <Zoltan.Menyhart@bull.net>
Cc: "Chen, Kenneth W" <kenneth.w.chen@intel.com>, 'Christoph Lameter' <clameter@sgi.com>, Zoltan Menyhart <Zoltan.Menyhart@free.fr>, akpm@osdl.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org

Zoltan Menyhart wrote:

>
> 4. Bit-lock operations:
>
> I summarized the ordering requirements here:
> http://marc.theaimsgroup.com/?l=linux-ia64&m4362989421046&w=2
>
> In order to let the architectures implement these bit-lock
> operations efficiently, the usage has to indicate the _minimal_
> required ordering semantics, e.g.:
>
>     test_and_set_bit_N_acquire()
> or   ordered_test_and_set_bit(acquire, ...)
>     release_N_clear_bit()
> etc.
>

The problem is simply that we don't expose acquire or release
ordering operations to AI kernel code (outside of locking, which
is a great wrapper). The reason is to avoid proliferation of all
these semantics.

If you do this then the powerpc guys will say they want all
their weird crap in there too. If you remove seperate read
and write barriers, then x86 and sparc64 folks will get upset
etc etc.

Changing semantics would probably require some fairly hefty
discussions. Can you first fix ia64, then (perhaps) introduce
lock semantics for the couple of bitops that can use it, then
can we see some performance justification for proposed
changes to the API?

--

Send instant messages to your online friends http://au.messenger.yahoo.com 
