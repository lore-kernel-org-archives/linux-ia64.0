From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date: Tue, 13 Jul 2004 17:38:06 +0000
Subject: Re: `PCDP_TABLE_GUID' undeclared
Message-Id: <200407131138.06674.bjorn.helgaas@hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <16619.35692.503174.993123@napali.hpl.hp.com>
In-Reply-To: <16619.35692.503174.993123@napali.hpl.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tuesday 06 July 2004 11:34 pm, David Mosberger wrote:
> I get this error when compiling pcdp.c with CONFIG_IA64_EARLY_PRINTK_UART
> enabled.  s/PCDP_TABLE_GUID/HCDP_TABLE_GUID/?

Yup (I see you've already fixed this).  Sorry, I was on vacation
all last week.
