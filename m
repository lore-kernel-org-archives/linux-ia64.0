From: "Luck, Tony" <tony.luck@intel.com>
Date: Thu, 08 May 2008 00:01:18 +0000
Subject: RE: [PATCH] ia64: allow user to skip_check_sal_cache_flush
Message-Id: <1FE6DD409037234FAB833C420AA843EC014B898A@orsmsx424.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20080507233614.GF5609@ldl.fc.hp.com>
In-Reply-To: <20080507233614.GF5609@ldl.fc.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> +early_param("skip_check_sal_cache_flush", skip_check_sal_cache_flush);

Please document this in Documentation/kernel-paramters.txt

Perhaps this would set the record for the longest kenrel parameter,
but I don't think this is a good thing.  Can you abbreviate while
still being descriptive?

-Tony

