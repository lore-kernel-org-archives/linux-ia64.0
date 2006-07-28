From: Prarit Bhargava <prarit@sgi.com>
Date: Fri, 28 Jul 2006 14:01:45 +0000
Subject: [PATCH 0/2] Fix RAID5 + IA64 compile
Message-Id: <20060728140145.9149.43458.sendpatchset@prarit.boston.redhat.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org, linux-scsi@vger.kernel.org
Cc: Prarit Bhargava <prarit@sgi.com>

Patchset to fix RAID5 on ia64.  Removes dead CONFIG options and
introduces a new CONFIG option.

Patch is against 2.6.17 + 2.6.18-rc2-git5

Signed-off-by: Prarit Bhargava <prarit@redhat.com>
