From: Martin Pool <mbp@samba.org>
Date: Thu, 07 Aug 2003 07:31:02 +0000
Subject: Re: 2.6 PATCH: Fix include/asm-ia64/machvec.h
Message-Id: <marc-linux-ia64-106024152720905@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106024096120438@msgid-missing>
In-Reply-To: <marc-linux-ia64-106024096120438@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On  7 Aug 2003, "H. J. Lu" <hjl@lucon.org> wrote:
> include/asm-ia64/machvec.h has
> 
> /* forward declarations: */
> ...
> struct irq_desc;
> ...
> typedef struct irq_desc *ia64_mv_irq_desc (unsigned int);
> 
> But struct irq_desc is never declared anywhere. Here is a patch to
> fix it.

I posted this yesterday and akpm accepted it.

-- 
Martin 
