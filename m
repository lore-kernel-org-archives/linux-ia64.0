From: Bjorn Helgaas <bjorn_helgaas@hp.com>
Date: Sat, 15 Mar 2003 00:01:46 +0000
Subject: Re: [Linux-ia64] [patch] 2.4.20-ia64-021210 unwind.c - allow unw_access_gr(r0)
Message-Id: <marc-linux-ia64-105590709806123@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805543@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805543@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thursday 13 March 2003 9:39 pm, Keith Owens wrote:
> Patch is against 2.4.20-ia64-021210.
> The patch allows unw_access_gr() to read from r0, to support unwind
> directives such as .save ar.pfs,r0 and .save rp,r0.

I applied this in the 2.4 tree, along with the other cleanups
from David's 2.5 tree.

Bjorn


