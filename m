From: Keith Owens <kaos@sgi.com>
Date: Wed, 08 Feb 2006 02:40:53 +0000
Subject: [PATCH 2.6.16-rc2 0/3] MCA: summary
Message-Id: <20060208024053.9264.60119.sendpatchset@kao2.melbourne.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Three small patches to MCA handling.

1 - Print messages giving the status of the MCA handler and the slaves.
2 - Update the comm field in the MCA handler if the MCA occurred in
    user space.
3 - Remove the obsolete PLATFORM_MCA_HANDLERS.

The patches are independent and can be applied in any order, although
the line numbers assume that they are applied in the above order.
