From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Tue, 13 Jul 2004 17:42:41 +0000
Subject: Re: `PCDP_TABLE_GUID' undeclared
Message-Id: <16628.7953.117558.610044@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <16619.35692.503174.993123@napali.hpl.hp.com>
In-Reply-To: <16619.35692.503174.993123@napali.hpl.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Tue, 13 Jul 2004 11:38:06 -0600, Bjorn Helgaas <bjorn.helgaas@hp.com> said:

  Bjorn> On Tuesday 06 July 2004 11:34 pm, David Mosberger wrote:
  >> I get this error when compiling pcdp.c with
  >> CONFIG_IA64_EARLY_PRINTK_UART enabled.
  >> s/PCDP_TABLE_GUID/HCDP_TABLE_GUID/?

  Bjorn> Yup (I see you've already fixed this).  Sorry, I was on
  Bjorn> vacation all last week.

I only fixed it in the ia64-tree.  Would you mind feeding it upstream?

Thanks,

	--david
