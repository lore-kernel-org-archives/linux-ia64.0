From: "Luck, Tony" <tony.luck@intel.com>
Date: Fri, 08 Jun 2007 04:33:09 +0000
Subject: RE: [IA64] Set default page size to 64k
Message-Id: <617E1C2C70743745A92448908E030B2A01A4962B@scsmsx411.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.64.0706071803570.14490@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.64.0706071803570.14490@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Other cases where large page size will hurt are where
the user application consists of a very large number of
small processes (since the memory footprint for a small
process will be almost quadrupled) or where small pieces
of large files (or a large number of small files) are
being randomly accessed (because of fragmentation in
the page cache).

But I've been thinking of switching over to 64K pages
for a while.  As you say ia64 systems tend to have a
large amount of memory ... and everyone's idea of
"large" when talking about memory has been gradually
increasing over the years (choice for laptops is now
1G or 2G!).  It would seem silly to provision an ia64
box with less than 16G of memory today.

-Tony
