From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Fri, 20 May 2005 15:03:11 +0000
Subject: Re: flush_icache_range
Message-Id: <17037.64559.251756.246131@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <4236D7B5.8050408@bull.net>
In-Reply-To: <4236D7B5.8050408@bull.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Fri, 20 May 2005 16:17:51 +0200, Zoltan Menyhart <Zoltan.Menyhart@bull.net> said:

  Zoltan> +#if	defined(CONFIG_ITANIUM)
  Zoltan> .Loop:	fc in0				// issuable on M0 only
  Zoltan> +#else
  Zoltan> +.Loop:	fc.i in0
  Zoltan> +#endif

Why this?  fc.i on Merced is a NOP (as it is on McKinley etc.).

	--david
