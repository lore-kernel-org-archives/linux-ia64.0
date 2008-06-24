From: Alex Chiang <achiang@hp.com>
Date: Tue, 24 Jun 2008 15:21:29 +0000
Subject: Re: [BISECT] Boot failure on ia64.
Message-Id: <20080624152129.GB3599@ldl.fc.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20080624123014.GJ10123@sgi.com> <20080624150851.GA3599@ldl.fc.hp.com> <20080624151715.GN10062@sgi.com>
In-Reply-To: <20080624151715.GN10062@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Robin Holt <holt@sgi.com>
Cc: tony.luck@intel.com, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

* Robin Holt <holt@sgi.com>:
> I have not tried your patch yet.  Actually just read the email.
> Jack Steiner did point out that booting with force_pal_cache_flush on
> the command line will get it to boot.

Yes, that command line arg will get your kernel to boot because
it forces us to completely skip check_sal_cache_flush. It's
probably not what you want to be using long term, though.

> I will try your patch shortly and send you output.

Thanks.

/ac

