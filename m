From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date: Tue, 08 Jun 2004 15:05:52 +0000
Subject: Re: Who owns those locks ?
Message-Id: <200406080905.52673.bjorn.helgaas@hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <40A1F4BE.4A298352@nospam.org> <200406070906.54132.bjorn.helgaas@hp.com> <40C572C8.20B13640@nospam.org>
In-Reply-To: <40C572C8.20B13640@nospam.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Zoltan.Menyhart@bull.net
Cc: linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

On Tuesday 08 June 2004 2:03 am, Zoltan Menyhart wrote:
> - You keep my code, it is correct for a memory size up to 16 Tbytes.

Many if not most large machines have sparse address spaces,
so you may have memory at an address that will cause a
problem even if the actual amount of memory is much smaller.

The main point is that I wouldn't want a time bomb that
will silently fail when somebody happens to boot on such
a machine.  Whether that's avoided by a "miraculous" bit,
throwing away problem pages at boot-time, avoiding task
allocation at specific addresses, etc.,  is secondary.
