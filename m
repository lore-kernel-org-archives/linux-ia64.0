From: "Luck, Tony" <tony.luck@intel.com>
Date: Mon, 13 Feb 2006 17:26:58 +0000
Subject: RE: [Patch]IA64 kexec
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F05B11D12@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1131406068.2524.15.camel@linux-znh>
In-Reply-To: <1131406068.2524.15.camel@linux-znh>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> Here is an as-yet untested forward port of the kexec-ia64 patch to
> today's Linus git tree (~2.6.16-rc3).

Thanks for taking a look at this ... I'm glad to see that there is
still interest in kexec.

Khalid Aziz at HP is woking on merging the good parts of that patch
from Nan Hai with the kexec patch that he had produced earlier).  We
should see the results of that merge next week, & I hope to see
lots more commentary and testing this time around.

> I haven't looked into what other features have been added 
> to other arches kexec. Nor if the features above are applicable -
> seems that they probably are, exept that ia64 doesn't have NMI
> (right?) so the cpu shutdown would need to be done another way.

Nan Hai makes use of HOTPLUG_CPU to offline the other cpus ... which
in many ways is a very elegant solution (as it puts the cpus neatly
back into SAL ready for the new OS to bring it back online again).
But there are a couple of downsides:
1) Requires CONFIG_HOTPLUG_CPU (perhaps this isn't really a big issue)
2) May run into trouble for kdump case where we'd like to rely on
less known state/code to get a good dump when the Linux kernel is
known to be in some unstable state.

The ia64 equivalent of NMI (large brick through the window) is INIT.
Some systems have a button on the front panel to generate INIT, or
have a maintenance processor that can send INIT.  So a good kdump
solution should eventually make use of INIT.

-Tony
