From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Tue, 13 Jan 2004 00:05:56 +0000
Subject: Re: [PATCH] sba_iommu update (2.6 version)
Message-Id: <16387.13924.837343.406109@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1073938588.6497.56.camel@patsy.fc.hp.com>
In-Reply-To: <1073938588.6497.56.camel@patsy.fc.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Mon, 12 Jan 2004 16:53:37 -0700, Alex Williamson <alex.williamson@hp.com> said:

  Alex> New patch below, let me know if you spot anything else.

Looks good to me.  Applied.

Thanks,

	--david

PS: I fixed get_order() in page.h to use "long double", too.
