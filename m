From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Sat, 18 Oct 2003 01:09:50 +0000
Subject: Re: [PATCH] fix EFI memory map trimming
Message-Id: <marc-linux-ia64-106643940222738@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106642910714855@msgid-missing>
In-Reply-To: <marc-linux-ia64-106642910714855@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Fri, 17 Oct 2003 16:13:44 -0600, Bjorn Helgaas <bjorn.helgaas@hp.com> said:

  Bjorn> This fixes a problem in EFI memory map trimming.  I've never
  Bjorn> been able to wrap my head around the existing code, so this
  Bjorn> is perhaps more of a rewrite than it ought to be, but
  Bjorn> ... well, you can see what you think.

I think it's a nice improvement and not too much of a rewrite.  Just
one small suggestion:

+			if (check_md->attribute & EFI_MEMORY_WB &&
+			    check_md->phys_addr = first_non_wb_addr)

This needs a pair of parens to avoid a compiler warning, I think.

	--david
