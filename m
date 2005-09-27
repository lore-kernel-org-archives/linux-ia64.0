From: "Luck, Tony" <tony.luck@intel.com>
Date: Tue, 27 Sep 2005 22:00:32 +0000
Subject: RE: [PATCH 0/4] V4 ia64 SPARSEMEM
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F0482A591@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20050922161418.GW16066@localhost.localdomain>
In-Reply-To: <20050922161418.GW16066@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>Okay. There was a bug in my Kconfig.  All defconfigs and my own memory model
>configs build correctly and produce the correct config options.  Below is
>a replacement for patch 1/4 which I've included for your config testing.  I'll
>post V5 patchset when we agree on where we want to proceed with config(s).  

Yup, all my configs now build too (includes some of the distributed ones
with CONFIG_SMP turned off).  I booted three sample kernels (zx1,
generic and generic with s/discontig/sparse/) on rx2620 with nothing
odd happening.

>I'm thinking all we need is sparsemem_defconfig which is defconfig but with
>the SPARSEMEM memory model.

That would do as a starting point ... it gives me an easy hook
into my automatic build script to make sure that SPARSEMEM is being
test compiled.

Do you have, or can you generate, the full list of all the combinations
of memory model related options that Kconfig will accept?

-Tony
