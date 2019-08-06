From: "Luck, Tony" <tony.luck@intel.com>
Date: Tue, 06 Aug 2019 17:23:39 +0000
Subject: RE: [PATCH] ia64:unwind: fix double free for mod->arch.init_unw_table
Message-Id: <3908561D78D1C84285E8C5FCA982C28F7F410413@ORSMSX115.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1565077593-72480-1-git-send-email-chenzefeng2@huawei.com>
In-Reply-To: <1565077593-72480-1-git-send-email-chenzefeng2@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: chenzefeng <chenzefeng2@huawei.com>, "Yu, Fenghua" <fenghua.yu@intel.com>
Cc: "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

> Here, set mod->arch.init_unw_table = NULL after remove the unwind
> table to avoid double free.

Applied. Thanks.

-Tony
