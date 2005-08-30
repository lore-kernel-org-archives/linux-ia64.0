From: "John W. Linville" <linville@tuxdriver.com>
Date: Tue, 30 Aug 2005 18:09:14 +0000
Subject: Re: [patch 2.6.13] swiotlb: add swiotlb_sync_single_range_for_{cpu,device}
Message-Id: <20050830180912.GE18998@tuxdriver.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <B8E391BBE9FE384DAA4C5C003888BE6F0443A4B5@scsmsx401.amr.corp.intel.com>
In-Reply-To: <B8E391BBE9FE384DAA4C5C003888BE6F0443A4B5@scsmsx401.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Luck, Tony" <tony.luck@intel.com>
Cc: linux-kernel@vger.kernel.org, Andi Kleen <ak@suse.de>, discuss@x86-64.org, linux-ia64@vger.kernel.org, Asit.K.Mallick@intel.com, goutham.rao@intel.com, davidm@hpl.hp.com

On Tue, Aug 30, 2005 at 11:03:35AM -0700, Luck, Tony wrote:
> 
> >+swiotlb_sync_single_range_for_cpu(struct device *hwdev, 
> >+swiotlb_sync_single_range_for_device(struct device *hwdev, 
> 
> Huh?  These look identical ... same args, same code, just a
> different name.

Have you looked at the implementations for swiotlb_sync_single_for_cpu
and swiotlb_sync_single_for_device?  Those are already identical.

I'm just following the existing style/practice in that file.  I could
do an additional patch to rectify the replication in those functions
if you'd like?

Who is responsible for the swiotlb code?

John
-- 
John W. Linville
linville@tuxdriver.com
