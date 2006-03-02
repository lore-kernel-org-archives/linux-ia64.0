From: Jack Steiner <steiner@sgi.com>
Date: Thu, 02 Mar 2006 22:02:15 +0000
Subject: PATCH[0/4] - Increase max node count on SN platforms
Message-Id: <20060302220215.GA15415@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Here is a series of patches that increases the maximun
number of nodes supported in SN SSI configurations. The
old limit was 256n. This limit has been increased to 1024n.

These patches should have no impact on any non-SN platform.
SN platforms are unchanged unless the new CONFIG_IA64_NR_NODES
option is set a value greater than 256. 

Two trivial non-IA64 patches are also required but this patch
can be applied without those patches. 

Detail descriptions in the follow on patches.


-- Jack


