From: Robin Holt <holt@sgi.com>
Date: Wed, 30 Sep 2009 00:54:53 +0000
Subject: Re: [git pull] ia64 changes
Message-Id: <20090930005453.GG8934@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1FE6DD409037234FAB833C420AA843EC0122AEB1@orsmsx424.amr.corp.intel.com>
In-Reply-To: <1FE6DD409037234FAB833C420AA843EC0122AEB1@orsmsx424.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Tony,

Any idea how difficult it will be to re-enable interrupts inside the
contended lock case?  Without thinking about it, it feels like it
will be impossible.  That is likely going to be a significant issue on
larger systems.

Thanks,
Robin
