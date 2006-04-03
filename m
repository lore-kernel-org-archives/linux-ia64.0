From: "David Mosberger-Tang" <David.Mosberger@acm.org>
Date: Mon, 03 Apr 2006 16:42:00 +0000
Subject: Re: accessed/dirty bit handler tuning
Message-Id: <ed5aea430604030942l19fa8f27t220f46a189a3f43a@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <44157CF1.5060902@bull.net>
In-Reply-To: <44157CF1.5060902@bull.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On 4/3/06, Zoltan Menyhart <Zoltan.Menyhart@bull.net> wrote:

> The problem is that the most frequently used trap handler contains
> the unsafe walk of the
>
>         rx = IA64_KR_PT_BASE -> pgd[i] -> pud[j] -> pmd[k] -> pte[l]
>
> chain...

Please, everybody step back a minute.  Hint: consider that x86 does
the page-table walk in hardware...

  --david
