From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date: Mon, 12 Jan 2004 21:57:15 +0000
Subject: Re: [PATCH] sba_iommu update (2.6 version)
Message-Id: <200401121457.15860.bjorn.helgaas@hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1073938588.6497.56.camel@patsy.fc.hp.com>
In-Reply-To: <1073938588.6497.56.camel@patsy.fc.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Monday 12 January 2004 1:16 pm, Alex Williamson wrote:
> +__setup("sbapagesize=",sba_page_override);

I still have this obsessive idea that we should get rid of the "sba"
references and replace them with "ioc".  Would this be a good time
to rename at least the "nosbagart" and "sbapagesize" arguments?

Bjorn

