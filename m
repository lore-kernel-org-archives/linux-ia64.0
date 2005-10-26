From: "Luck, Tony" <tony.luck@intel.com>
Date: Wed, 26 Oct 2005 19:02:27 +0000
Subject: RE: [PATCH] kexec on ia64
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F04C8C5D1@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1100550721.26287.32.camel@lyra.fc.hp.com>
In-Reply-To: <1100550721.26287.32.camel@lyra.fc.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> Cool.  Tony, what are your plans for pushing this to Linus?  Will it make 
> 2.6.15?

Nanhai Zou here at Intel expressed a few concerns to me last night
about Khalid's patch.  I'll paste them here to speed discussion about
this (as I expect Nanhai is asleep at the moment, he should be
around to start commenting for himself by 4-5pm Pacific).

> I think his patch is still not able to boot an unmodified kernel.
> It appends a kernel parameter to bypass the issue, thus the second kernel need to be modified.

> It also hardcoded initrd logic in kernel patch.
> Command line is still using old command line.
> No purgatory code support etc.

> How, I prefer to put a small and clean patch in kernel while leave most of the things in kexec-tools. 
> That will provide more flexibility.

> There are also some other issues I can see, like, 
> 1. icache flusing miss
> 2. rendez code is fake, I prefer to use hotplug API.
> 3. Disable PCI master code should be in generic PCI driver code instead of IA64 arch code.

Nanhai has his own patches for kexec/kexec-tools, which are
stuck in some Intel bureaucracy at the moment ...  I'm trying
to get them unstuck so that we can get some meaningful
commentary from the community about both versions.

My biggest issue with both patches at the moment is that I
can't see how either of them can be extended to be useful
for use in crash-dump case without some significant surgery.
Both of them over-write the existing kernel with the new one,
which is a big problem when you'd like to dump the data space
of the old kernel.  Ia64 is quite happy to run a kernel loaded
at any suitably aligned address ... so why not load the new
kernel in some different location from the old kernel?

Including this in 2.6.15?  It's possible, but it's looking like
this might be a rush.  Assuming Linus releases 2.6.14 by the
end of this week, we only have a couple of weeks to check that
this runs on all of the weird configurations.  I'd need to see
a lot of "tested on xxx-config ... no problems" e-mail to get
confidence in this.

-Tony
