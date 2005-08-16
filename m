From: Mark Goodwin <markgw@sgi.com>
Date: Tue, 16 Aug 2005 07:49:50 +0000
Subject: [PATCH 0/3] - SGI SN hwperf enhancements - overview
Message-Id: <Pine.LNX.4.62.0508161724120.7676@woolami.melbourne.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


Tony,

The following series of three patches update the SGI SN platform
"hwperf" facility as follows:

(1) export PCI topology information,

(2) add a new exported function for determining the nearest node
    with CPUs for I/O nodes and fix a bug where the hwperf dynamic
    misc device was being registered before misc_init(), and

(3) update the SN pci device info to use the nearest node function
    to allocate driver memory on the nearest node (rather than
    defaulting to node 0).

All files are in the arch/ia64/sn portion of the tree & should
have no effect on non-SN platforms. They should be applied after
Jack Steiner's recent series of 7 patches.

Thanks
-- Mark Goodwin
SGI Engineering

