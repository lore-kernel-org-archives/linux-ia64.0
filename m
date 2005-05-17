From: Keith Owens <kaos@sgi.com>
Date: Tue, 17 May 2005 07:37:39 +0000
Subject: Allocating uncacheable memory from OS
Message-Id: <11503.1116315459@kao2.melbourne.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Is there any ia64 OS routine for allocating uncacheable memory?  I am
trying to simulate the SAL/OS interface for MCA handling and the
min-state area is expected to be uncacheable.

