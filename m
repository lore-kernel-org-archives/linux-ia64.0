From: Jes Sorensen <jes@sgi.com>
Date: Tue, 22 Apr 2008 09:16:41 +0000
Subject: Re: [PATCH 04/15] ia64/pv_ops: introduce pv_info which describes some random info.
Message-Id: <yq04p9ul05i.fsf@jaguar.mkp.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <12077165491881-git-send-email-yamahata@valinux.co.jp>
In-Reply-To: <12077165491881-git-send-email-yamahata@valinux.co.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> "Isaku" = Isaku Yamahata <yamahata@valinux.co.jp> writes:

Isaku> introduce pv_info which describes some randome info about
Isaku> underlying execution environment.

Hi Isaku,

I am missing some of the patches in this series for some reason.
However, I'd like to open the discussion and ask why you are
implementing the pv-ops seperately instead of adding them to the
machine vectors and using the machine vector interface to handle the
direct implementation?

It seems to me that pvops really are just an advanced level of the
ia64 machine vectors and building on top of the interface we already
have would make it easier to support different machine types through
pvops.

Cheers,
Jes
