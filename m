From: Alex Williamson <alex.williamson@hp.com>
Date: Mon, 12 Jan 2004 23:01:49 +0000
Subject: Re: [PATCH] sba_iommu update (2.6 version)
Message-Id: <1073948508.6497.128.camel@patsy.fc.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1073938588.6497.56.camel@patsy.fc.hp.com>
In-Reply-To: <1073938588.6497.56.camel@patsy.fc.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Mon, 2004-01-12 at 14:57, Bjorn Helgaas wrote:
> On Monday 12 January 2004 1:16 pm, Alex Williamson wrote:
> > +__setup("sbapagesize=",sba_page_override);
> 
> I still have this obsessive idea that we should get rid of the "sba"
> references and replace them with "ioc".  Would this be a good time
> to rename at least the "nosbagart" and "sbapagesize" arguments?

   That is an obsessive idea ;^)  I don't have strong opinions either
way.  I do like that currently "sba" boot parameters change the behavior
of the "sba" code.  So while it makes sense that it probably should be
called iocpagesize, I'm reluctant to do it piece-wise.  These parameters
are intentionally not documented anywhere outside of the code, so I
don't think changing them at some later point will cause too many
problems.  Thanks,

	Alex

-- 
Alex Williamson                             HP Linux & Open Source Lab

