From: Keith Owens <kaos@sgi.com>
Date: Thu, 04 Mar 2004 23:41:10 +0000
Subject: Re: [PATCH] 2.4.25: BUG(): Use guard page instead of page 0
Message-Id: <11811.1078443670@ocs3.ocs.com.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040218221302.GA87364@dragonfly.csd.sgi.com>
In-Reply-To: <20040218221302.GA87364@dragonfly.csd.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, 4 Mar 2004 16:25:00 -0700, 
Bjorn Helgaas <bjorn.helgaas@hp.com> wrote:
>How about the following?  I like the idea of using the guard page
>instead of address 0, but I sort of hate to add another magic number
>(though I guess you could argue that "0" is almost as magic as
>"0xa000000000000000").

Why not use 'break 0' for gcc < 3.1?  No need to worry about which
pages are protected.

        switch (break_num) {
              case 0: /* unknown error (used by GCC for __builtin_abort()) */
                die_if_kernel("bugcheck!", regs, break_num);

