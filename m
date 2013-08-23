From: David Miller <davem@davemloft.net>
Date: Fri, 23 Aug 2013 05:21:42 +0000
Subject: Re: [PATCH 2/2] fs: use inode_set_user to set uid/gid of inode
Message-Id: <20130822.222142.765878355588087442.davem@davemloft.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <1377226118-43756-1-git-send-email-rui.xiang@huawei.com>
	<1377226118-43756-3-git-send-email-rui.xiang@huawei.com>
In-Reply-To: <1377226118-43756-3-git-send-email-rui.xiang@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: rui.xiang@huawei.com
Cc: linux-fsdevel@vger.kernel.org, viro@zeniv.linux.org.uk, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, linux-rdma@vger.kernel.org, linux-usb@vger.kernel.org, v9fs-developer@lists.sourceforge.net, linux-mm@kvack.org, cgroups@vger.kernel.org, netdev@vger.kernel.org

From: Rui Xiang <rui.xiang@huawei.com>
Date: Fri, 23 Aug 2013 10:48:38 +0800

> Use the new interface to set i_uid/i_gid in inode struct.
> 
> Signed-off-by: Rui Xiang <rui.xiang@huawei.com>

For the networking bits:

Acked-by: David S. Miller <davem@davemloft.net>
