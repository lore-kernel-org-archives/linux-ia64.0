From: "Luck, Tony" <tony.luck@intel.com>
Date: Mon, 17 Nov 2008 19:45:38 +0000
Subject: RE: [PATCH] Ensure PSR.ac is cleared for early userspace
Message-Id: <57C9024A16AD2D4C97DC78E552063EA35C3BE3A2@orsmsx505.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200811120135.mAC1ZoSd017352@agluck-lia64.sc.intel.com>
In-Reply-To: <200811120135.mAC1ZoSd017352@agluck-lia64.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> If the hypothesis is that test and development kernels would catch the
> alignment problems, then there shouldn't be any in the production
> kernels right?  However, if there _are_ any out there in production
> don't we want them to become visible?  Even on processors which can
> handle them it is still better to not have the unaligned acesses in the
> first place right?

I was thinking of the case where someone loads a module that has
not had the benefit of being developed in an environment where all
the unaligned accesses could be easily seen and removed.  It seems
(to me) that the user of that system would be happier to have the
flow of "unaligned access" messages on the console reduced by letting
the h/w handle the ones that it could.

It is definitely better to avoid the unaligned access completely,
but I'm not sure this is possible in practice.

-Tony
