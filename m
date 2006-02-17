From: "Luck, Tony" <tony.luck@intel.com>
Date: Fri, 17 Feb 2006 17:14:07 +0000
Subject: RE: [patch] option to quite unaligned trap warnings
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F05BBF345@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <yq0hd772nhj.fsf@jaguar.mkp.net>
In-Reply-To: <yq0hd772nhj.fsf@jaguar.mkp.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Jes> Hi, This patch is an attempt to find a good compromise to the
Jes> somewhat contentious issue of the unaligned usertrap warnings.

> I haven't seen any negative reactions to this one yet and it's been a
> week so far. Tony any chance you would apply it to your tree?

Yes, though I might trim the printk() message back a bit, it seems
a bit[1] over the top.  How about just:

Unaligned exception warnings have been disabled
echo 0 > /proc/sys/kernel/ignore-unaligned-usertrap to re-enable

-Tony

[1] more than a bit, hundreds of bytes
