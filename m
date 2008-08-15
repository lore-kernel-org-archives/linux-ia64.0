From: Robin Holt <holt@sgi.com>
Date: Fri, 15 Aug 2008 18:32:57 +0000
Subject: Re: Pondering machvec ... was: [Patch] Remove sn2_defconfig.
Message-Id: <20080815183257.GP6824@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <57C9024A16AD2D4C97DC78E552063EA309B82A07@orsmsx505.amr.corp.intel.com>
In-Reply-To: <57C9024A16AD2D4C97DC78E552063EA309B82A07@orsmsx505.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

I am not addressing anything other than the sn2_defconfig, but it
has gotten so stale that nobody I know inside SGI uses it any longer.
We either maintain our own config file or start with the generic_defconfig
and adjust the things we need.

If any of our engineers wanted to eliminate the mach_vec stuff, we would
likely start from the generic_defconfig and change _GENERIC to _SN2.

On Fri, Aug 15, 2008 at 10:20:03AM -0700, Luck, Tony wrote:
> >    Not really a patch as much as a remove this file request.  Now that
> >    generic_defconfig supports all the configurations SGI currently supports
> >    and has NR_CPUS and NR_NODES at our largest configurations, we have no
> >    reason to maintain the extra defconfig file.
> 
> I'm wondering whether we really want to do this ... and in turn wondering
> about the value of the "generic" vs. system specific config files and the
> whole machvec mechanism.

I don't think I understand your argument.  Are you essentially saying we
should consider eliminating the mach_vec stuff entirely?  If so, will
we essentially be saying that the distros need to build a seperate kernel
for each of tiger, zx1, sn2, and uv?

Thanks,
Robin
