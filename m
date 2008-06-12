From: "Luck, Tony" <tony.luck@intel.com>
Date: Thu, 12 Jun 2008 00:24:06 +0000
Subject: RE: [PATCH] Update check_sal_cache_flush to use platform_send_ipi()
Message-Id: <1FE6DD409037234FAB833C420AA843EC018C1E08@orsmsx424.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20080611232927.GC29736@ldl.fc.hp.com>
In-Reply-To: <20080611232927.GC29736@ldl.fc.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> This is the patch you asked for on irc. I didn't test on any
> virtualization platforms (kvm, xen, etc.) because I didn't know
> which ones were troublesome.
>
> Would you mind verifying them for me?

Thanks Alex.  The patch looks good to me.  I've sent it to
the internal group that reported this to me for testing.

-Tony
