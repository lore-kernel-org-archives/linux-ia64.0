From: Prarit Bhargava <prarit@sgi.com>
Date: Thu, 09 Feb 2006 01:06:14 +0000
Subject: [PATCH 0/2]: Tollhouse Hotplug Support
Message-Id: <20060209010549.26182.18553.sendpatchset@prarit.boston.redhat.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

This patchset corrects hotplug slots' physical_path for Tollhouse systems.

The first patch is a patch to the ia64 portion of the tree.

The second patch is a patch to drivers/pci/hotplug/sgi_hotplug.c .

Tony (Luck) -- the first patch [1/2] will compile on its own.  After that is in
Linus' tree I'll ping Greg KH and ask him to commit the sgi_hotplug fix in his
next git patchset.

Thanks :o)

P.

