From: "Luck, Tony" <tony.luck@intel.com>
Date: Wed, 28 May 2008 19:55:21 +0000
Subject: RE: [PATCH 00/17] ia64/pv_ops take 6
Message-Id: <1FE6DD409037234FAB833C420AA843EC016FFB71@orsmsx424.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <12112028241775-git-send-email-yamahata@valinux.co.jp>
In-Reply-To: <12112028241775-git-send-email-yamahata@valinux.co.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> Since the effort to reduce code size had already been made, so 
> it is difficult to go further. By moving all of them, it would
> be consistent and we don't have to worry about code size anymore.

I've been caught by these a number of times while adding debug/monitor
hooks to ivt.S code.  Moving all of these squatters out is a good idea.

Thank you. Applied.

-Tony
