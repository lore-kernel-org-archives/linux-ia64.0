From: "Luck, Tony" <tony.luck@intel.com>
Date: Thu, 13 May 2004 16:07:23 +0000
Subject: RE: [RFC] I/O MCA recovery
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F013CCE76@scsmsx401.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200405040954.09524.jbarnes@engr.sgi.com>
In-Reply-To: <200405040954.09524.jbarnes@engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>Thanks Tony, I hadn't looked at that code in awhile.  I guess 
>the I/O error recovery code should try to acquire the
>io_range_list_lock before looking through the list.

Yes ... I wouldn't attempt anything tricker than a "trylock"
in code that's going to run as part of an MCA handler.  The
async delivery of MCA means that there's always a risk of
deadlocking a cpu if it tries to grab a lock that it already
holds at the time the MCA is delivered.

-Tony
