From: "Luck, Tony" <tony.luck@intel.com>
Date: Thu, 23 Jan 2014 17:38:31 +0000
Subject: RE: Kernel compiled with gcc-4.6+ fails to boot on ia64
Message-Id: <3908561D78D1C84285E8C5FCA982C28F31DB5905@ORSMSX106.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <3908561D78D1C84285E8C5FCA982C28F31DB1BDA@ORSMSX106.amr.corp.intel.com>
In-Reply-To: <3908561D78D1C84285E8C5FCA982C28F31DB1BDA@ORSMSX106.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> So, I would be interested if Intel/hp developers (Tony? Hongjiu?
> Fenghua?) can add comments to clarify how ia64 kernel development
> works and how is it possible that this issue isn't affecting every
> ia64 users.

I build latest Linus and linux-next kernels to keep on top of Linux changes
that break ia64.  But I do this on top of a distro-installed system and
use whatever default gcc version comes with it.  Currently using gcc 4.3.4
which hasn't had any problems.

-Tony
