From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Thu, 06 Jun 2002 03:16:24 +0000
Subject: Re: [Linux-ia64] kernel update (relative to v2.5.18)
Message-Id: <marc-linux-ia64-105590701905646@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205111@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205111@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Thu, 06 Jun 2002 12:01:06 +1000, Peter Chubb <peter@chubb.wattle.id.au> said:

  Peter> -- perfmon_itanium.h is missing.  I used the one from the 2.4
  Peter> tree.

My mistake.  I added it now.

  Peter> -- With CONFIG_GENERIC, sba_iommu.c still doesn't
  Peter> compile because of the removal of the address field from the
  Peter> scatterlist.

Yes.  Grant said he's going to work on this.

  Peter> -- Again with CONFIG_GENERIC, there are problems:

  Peter> include/asm/machvec.h:83:12: warning: pasting "machvec_hpsim"
  Peter> and "."  does not give a valid preprocessing token
  Peter> include/asm/machvec_init.h:26: initializer element is not
  Peter> constant include/asm/machvec_init.h:26: (near initialization
  Peter> for `machvec_hpsim.dma_supported')
  Peter> include/asm/machvec_init.h:26: `__ia64_mmiob' undeclared here
  Peter> (not in a function) include/asm/machvec_init.h:26:
  Peter> initializer element is not constant

I don't use GENERIC myself usually.  A patch is always welcome, of course.

  Peter> 	-- I think you need this little patch in
  Peter> ia64/kernel/signal.c otherwise the usual case will fall off
  Peter> the bottom of the function without a return value.

Yes, indeed.  Thanks for catching that.

  Peter> 	 -- asm/suspend.h doesn't exist, so do_mounts.c won't
  Peter> compile.  I just created an empty file.

Ah, yes.  It's arguably a bug in 2.5, but it seems like Linus wants
each arch to add that file, even if it's unused.  I'll re-check next
time I work on 2.5 and add it if it's still needed.

	--david

