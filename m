From: David Mosberger <davidm@hpl.hp.com>
Date: Tue, 05 Feb 2002 21:26:03 +0000
Subject: Re: [Linux-ia64] Proper fix for sym53c8xx_2 driver and dma64_addr_t
Message-Id: <marc-linux-ia64-105590698805994@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805991@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805991@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Tue, 05 Feb 2002 12:43:17 -0800, Michael Madore <mmadore@turbolinux.com> said:

  Michael> Hi, Back in early december, it was brought up that eh
  Michael> sym53c8xx_2 driver makes use of dma64_addr_t, which is not
  Michael> defined on IA64.  I got the impression that it was the
  Michael> driver that needed to be modified to correct the problem,
  Michael> but I don't recall seeing a specific solution.  I was going
  Michael> to simply replace dma64_addr_t with u64 in sym_glue.c for
  Michael> now.  Is there a better way?

That's what I did.

	--david

