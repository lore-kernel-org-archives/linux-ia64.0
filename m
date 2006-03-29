From: Grant Grundler <iod00d@hp.com>
Date: Wed, 29 Mar 2006 19:11:32 +0000
Subject: Re: Fix unlock_buffer() to work the same way as bit_unlock()
Message-Id: <20060329191132.GD31225@esmail.cup.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <65953E8166311641A685BDF71D865826A23CF1@cacexc12.americas.cpqcorp.net>
In-Reply-To: <65953E8166311641A685BDF71D865826A23CF1@cacexc12.americas.cpqcorp.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Boehm, Hans" <hans.boehm@hp.com>
Cc: Christoph Lameter <clameter@sgi.com>, "Chen, Kenneth W" <kenneth.w.chen@intel.com>, Nick Piggin <nickpiggin@yahoo.com.au>, Zoltan Menyhart <Zoltan.Menyhart@free.fr>, akpm@osdl.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org

On Wed, Mar 29, 2006 at 10:33:57AM -0800, Boehm, Hans wrote:
...
> - At user level, the ordering semantics required for something like
> pthread_mutex_lock() are unfortunately unclear.  If you try to interpret
> the current standard, you arrive at the conclusion that
> pthread_mutex_lock() basically needs a full barrier, though
> pthread_mutex_unlock() doesn't.  (See
> http://www.hpl.hp.com/techreports/2005/HPL-2005-217.html .)

Was the talk you presented at the May 2005 Gelato meeting in Cupertino
based on an earlier version of this paper?

That was a very good presentation that exposed the deficiencies
in the programming models and languages.  If the slides and/or
a recording are available, that might be helpful here too.

thanks,
grant
