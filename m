From: "KOCHI, Takayoshi" <t-kouchi@mvf.biglobe.ne.jp>
Date: Fri, 02 Aug 2002 22:01:49 +0000
Subject: Re: [Linux-ia64] [PATCH] dynamic IRQ allocation
Message-Id: <marc-linux-ia64-105590701905896@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701905851@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701905851@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Fri, 2 Aug 2002 14:22:41 -0700
David Mosberger <davidm@napali.hpl.hp.com> wrote:

> >>>>> On Fri, 02 Aug 2002 10:45:11 -0700, "KOCHI, Takayoshi" <t-kouchi@mvf.biglobe.ne.jp> said:
> 
>   >>  register_irq() -> register_intr()
> 
> No can do.  At the platform-independent level, we have to accommodate
> the Linux irq naming convention.  (In the book I used the name "irq
> number" to make it clearer that this is just a logical number, not
> necessarily something corresponding to a physical line.)

Did you take register_irq() for request_irq()?

register_irq() is declared as static void register_irq(...) in
iosapic.c.

It does pretty iosapic-dependent stuff.

Thanks,
-- 
KOCHI, Takayoshi <t-kouchi@cq.jp.nec.com/t-kouchi@mvf.biglobe.ne.jp>


