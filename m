From: Andrew Morton <akpm@osdl.org>
Date: Fri, 11 Jul 2003 07:30:47 +0000
Subject: Re: 2.5.75 out
Message-Id: <marc-linux-ia64-105790866000905@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105788013113852@msgid-missing>
In-Reply-To: <marc-linux-ia64-105788013113852@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

"Luck, Tony" <tony.luck@intel.com> wrote:
>
> diff ~/BK/david2.5/drivers/char/agp/i460-agp.c drivers/char/agp/i460-agp.c
>  611c611
>  >       .remove         = agp_intel_i460_remove,
>  ---
>  <       .remove         = __exit_p(agp_intel_i460_remove),

This should be __devexit_p(), yes?

I'll send a patch in.
