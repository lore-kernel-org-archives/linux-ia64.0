From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Date: Fri, 09 Jul 2004 21:10:18 +0000
Subject: RE: Deadly bug in fsys_gettimeofday
Message-Id: <200407092107.i69L7pY17801@unix-os.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200407092100.i69L0bY17642@unix-os.sc.intel.com>
In-Reply-To: <200407092100.i69L0bY17642@unix-os.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Chen, Kenneth W wrote on Friday, July 09, 2004 2:03 PM
>
> The order of reading ar.itc is incorrect with respect to all other variables
> in fsys_gettimeofday.  All variables involved in time interpolation need to be
> protected by the sequence lock xtime_lock for consistency check.  However, the
> first time that fsys_gettimeofday take a time stamp, it read the count outside
> the seq lock and leading to the following time leap into the future scenario:

Sorry, keep on forgetting the signed off trailer.

Signed-off-by: Ken Chen <kenneth.w.chen@intel.com>
Signed-off-by: Asit Mallick <asit.k.mallick@intel.com>


