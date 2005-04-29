From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Fri, 29 Apr 2005 07:09:49 +0000
Subject: Re: write_unlock: replace clear_bit with byte store
Message-Id: <17009.56765.605740.157840@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.58.0504281329150.23584@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.58.0504281329150.23584@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Thu, 28 Apr 2005 15:05:16 -0700 (PDT), Christoph Lameter <clameter@engr.sgi.com> said:

  Christoph> +	u8 *y = (u8 *)x;

Same comments as before...

  Christoph> +	asm volatile ("st1.rel.nta [%0] = r0\n\t" :: "r"(y+3) : "memory" );

Let's not reintroduce in-line asm, please?

	--david
