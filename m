From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Thu, 20 May 2004 01:10:40 +0000
Subject: Re: Kill warnings in 2.6.6
Message-Id: <16556.1424.252715.885634@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <E1BQFaq-0003bB-KT@wombat.disy.cse.unsw.edu.au>
In-Reply-To: <E1BQFaq-0003bB-KT@wombat.disy.cse.unsw.edu.au>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


 Peter> === arch/ia64/kernel/machvec.c 1.7 vs edited == Peter> --- 1.7/arch/ia64/kernel/machvec.c	Thu Mar 18 16:57:15 2004
 Peter> +++ edited/arch/ia64/kernel/machvec.c	Tue May 18 13:00:35 2004
 Peter> @@ -61,6 +61,9 @@
 Peter>  }
 Peter>  EXPORT_SYMBOL(machvec_timer_interrupt);
 Peter>  
 Peter> +struct device;
 Peter> +struct scatterlist;
 Peter> +
 Peter>  void
 Peter>  machvec_dma_sync_single (struct device *hwdev, dma_addr_t dma_handle, size_t size, int dir)

Where does this get rid of a warning?  A driver or something else?

	--david
