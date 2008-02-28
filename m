From: Matthew Wilcox <matthew@wil.cx>
Date: Thu, 28 Feb 2008 00:42:58 +0000
Subject: Re: Tiger oops in ia64_sal_physical_id_info (was [RFC] regression:113134fcbca83619be4c68d0ca66db6093
Message-Id: <20080228004258.GD29360@parisc-linux.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <200802251027.15107.bjorn.helgaas@hp.com>
In-Reply-To: <200802251027.15107.bjorn.helgaas@hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, Feb 27, 2008 at 06:34:02PM -0600, Russ Anderson wrote:
> > +	if (ia64_platform_is("sn2")
> > +		&& (sal_revision = SAL_VERSION_CODE(2, 9))
> > +		&& (sal_version = SAL_VERSION_CODE(1, 90)))
> 
> The sal_version check should be removed.  The revision has been
> stuck at 2.9 but the version has been changing.

What would the right values be for a, b, c, d, e, f to make this work?

	if (ia64_platform_is("sn2") &&
	    sal_revision <= SAL_VERSION_CODE(3, 2)) {
		if (sal_version >= SAL_VERSION_CODE(a, b))
			sal_revision = SAL_VERSION_CODE(3, 2);
		else if (sal_version >= SAL_VERSION_CODE(c, d))
			sal_revision = SAL_VERSION_CODE(3, 1);
		else if (sal_version >= SAL_VERSION_CODE(e, f))
			sal_revision = SAL_VERSION_CODE(3, 0);
	}

-- 
Intel are signing my paycheques ... these opinions are still mine
"Bill, look, we understand that you're interested in selling us this
operating system, but compare it to ours.  We can't possibly take such
a retrograde step."
