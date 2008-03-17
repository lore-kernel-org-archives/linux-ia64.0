From: Robin Holt <holt@sgi.com>
Date: Mon, 17 Mar 2008 12:22:03 +0000
Subject: Re: [Patch 0/3] Modify how per_cpu allocations are done. -V8
Message-Id: <20080317122203.GE2013@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20080213175519.892353127@attica.americas.sgi.com>
In-Reply-To: <20080213175519.892353127@attica.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Mon, Mar 17, 2008 at 07:12:40AM -0500, holt@sgi.com wrote:
> This patchset cleans up how per_cpu reservations are done.

Argh, this should have been a better description and really only
and RFC instead of a patch.

I updated the patch to have the early_cpu_possible_mask in both
the contig and discontig cases.  This allows the mca stack allocator
to use that for preallocation instead of cpu_possible_map.  In the
case of !CONFIG_ACPI, the early_cpu_possible_mask = cpu_possible_mask.

I did find a tiger box (that is the same as a McKinnley SDV, correct?) to
try this on, but the serial console is messed up on that machine and it
so I will test this out when I get to the office.  If you get a chance
first, please let me know if it works.

Thanks,
Robin
