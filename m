From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Thu, 31 Jul 2003 00:32:50 +0000
Subject: Re: [PATCH] more discontig fun
Message-Id: <marc-linux-ia64-105961167211715@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105942849830042@msgid-missing>
In-Reply-To: <marc-linux-ia64-105942849830042@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


  Jesse> On Wed, Jul 30, 2003 at 10:17:13AM -0700, Jesse Barnes wrote:
  >> Ok, I'll fix this too.  Thanks for looking at it.

  Jesse> Does this look better?

Not really.

  Jesse> -efi_memmap_walk (efi_freemem_callback_t callback, void *arg)
  Jesse> +efi_memmap_walk (efi_freemem_callback_t callback, void *arg, void *arg2)

Why is this necessary?  Why not just pack that extra argument into a
structure and pass the whole thing to "arg"?

	--david
