From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Mon, 20 Oct 2003 18:55:39 +0000
Subject: Re: [PATCH] fix EFI memory map trimming
Message-Id: <marc-linux-ia64-106667619324540@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106642910714855@msgid-missing>
In-Reply-To: <marc-linux-ia64-106642910714855@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Mon, 20 Oct 2003 09:54:16 -0600, Bjorn Helgaas <bjorn.helgaas@hp.com> said:

  Bjorn> On Friday 17 October 2003 7:09 pm, David Mosberger wrote:
  >> +			if (check_md->attribute & EFI_MEMORY_WB &&
  >> +			    check_md->phys_addr = first_non_wb_addr)

  >> This needs a pair of parens to avoid a compiler warning, I think.

  Bjorn> gcc-3.3.2 doesn't warn either way, but here's a version with
  Bjorn> the extra parens:

Huh, you're right (neither does gcc-2.96, for example).  My mistake.
Still, I think the code is clearer with parens.

I applied the patch now, thanks.

	--david
