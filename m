From: Christoph Lameter <clameter@sgi.com>
Date: Wed, 29 Mar 2006 02:23:24 +0000
Subject: Re: Fix unlock_buffer() to work the same way as bit_unlock()
Message-Id: <Pine.LNX.4.64.0603281822570.18374@schroedinger.engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200603281853.k2SIrGg28290@unix-os.sc.intel.com> <4429ADBC.50507@free.fr>
 <Pine.LNX.4.64.0603281537500.15037@schroedinger.engr.sgi.com>
 <4429CFCA.7010201@yahoo.com.au>
In-Reply-To: <4429CFCA.7010201@yahoo.com.au>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Zoltan Menyhart <Zoltan.Menyhart@free.fr>, "Chen, Kenneth W" <kenneth.w.chen@intel.com>, akpm@osdl.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org

On Wed, 29 Mar 2006, Nick Piggin wrote:

> However, I think it might be reaonsable to use bit lock operations for
> in places like page lock and buffer lock (ie. with acquire and relese
> semantics). It improves ia64 without harming other architectures, and
> also makes the code more expressive.

How would be express the acquire and release semantics?
