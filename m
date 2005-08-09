From: "Luck, Tony" <tony.luck@intel.com>
Date: Tue, 09 Aug 2005 20:57:07 +0000
Subject: RE: purpose of modular mca recovery
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F041A2022@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20050809203915.GB28917@lst.de>
In-Reply-To: <20050809203915.GB28917@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>is there any reason to built this code modular?  After all it would
>usually not be loaded when it was needed.  Not allowing modular mca
>recovery would help greatly because it's using some symbols that we'd
>prefer to unexport before chaning some implementation details
>(tasklist_lock and maybe force_sig)

At the moment there are two reasons:
1) OS distributors don't trust this code very much and they seem to
prefer to ship a kernel that doesn't have mca memory recovery enabled.
But some do seem ok with the idea of supplying a module that a
suitably knowlegable customer would load.  This doesn't seem too
unreasonable a position, after all memory error recovery does involve
killing user applications.

2) Loading/unloading the module provides a mechanism to enable/disable
memory error recovery ... so we aren't tempted to add some ugly file in
/proc to do this.

Neither of these are really strong long-term arguments, but I'd prefer
to keep things this way for a while longer until we can convice a
few more people that this is good code to have built in as the default.

-Tony
