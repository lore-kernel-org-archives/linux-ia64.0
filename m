From: Keith Owens <kaos@sgi.com>
Date: Fri, 13 Feb 2004 00:55:04 +0000
Subject: Re: [patch] 2.4.25-rc1 Delete redundant ia64_mca_check_errors
Message-Id: <2947.1076633704@kao2.melbourne.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <2539.1076632333@kao2.melbourne.sgi.com>
In-Reply-To: <2539.1076632333@kao2.melbourne.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, 12 Feb 2004 16:47:46 -0800, 
David Mosberger <davidm@napali.hpl.hp.com> wrote:
>>>>>> On Fri, 13 Feb 2004 11:32:13 +1100, Keith Owens <kaos@sgi.com> said:
>
>  Keith> salinfo automatically processes all record types on all cpus
>  Keith> at boot time, ia64_mca_check_errors is now redundant.  This
>  Keith> also removes the need for a called_from_init flag on
>  Keith> ia64_mca_log_sal_error_record.
>
>The patch fails to apply:
>can't find file to patch at input line 30
>Perhaps you used the wrong -p or --strip option?
>The text leading up to this was:
>--------------------------
>|Index: 25-rc1.10/arch/ia64/kernel/pci.c

You applied the 2.4 patch to a 2.6 tree.  TGIF.

