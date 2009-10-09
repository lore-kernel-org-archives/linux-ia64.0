From: Nick Piggin <npiggin@suse.de>
Date: Fri, 09 Oct 2009 02:12:51 +0000
Subject: ticket spinlocks and sizeof(struct dentry)
Message-Id: <20091009021251.GA4287@wotan.suse.de>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi guys,

Just to let you know you may have turned sizeof(struct dentry) into
something nasty with 64 bit spinlocks (like 200 bytes) which would
mean a significant number (~half?) of dentries will cover 3 cachelines
instead of 2.

If I'm nost mistaken, this would probably be worth correcting.

Thanks,
Nick
