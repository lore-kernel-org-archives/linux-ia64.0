From: Christoph Lameter <clameter@sgi.com>
Date: Thu, 12 Oct 2006 19:18:08 +0000
Subject: [PATCH 0/4] Virtual Memory Map cleanup / improvements
Message-Id: <20061012191808.21498.63482.sendpatchset@schroedinger.engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

The following patchset cleans up the virtual memory map handling on IA64.

As an added bonus we make the virtual memory map static. This means that
basic VM operations do no longer need to get the memory map pointer but
will work with a static definition provided via the linker.

