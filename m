From: "Luck, Tony" <tony.luck@intel.com>
Date: Thu, 10 Feb 2005 01:05:52 +0000
Subject: RE: [patch 2.6.11-rc3-bk4] Correctly dereference ia64_mca_data
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F02E2BE51@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <23464.1107851114@kao2.melbourne.sgi.com>
In-Reply-To: <23464.1107851114@kao2.melbourne.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>Am I seeing this right: the path doesn't save practically nothing
>other than what is saved in the PAL min-state area?  The path
>presumably also ought to switch the register-backing store (I think
>Keith alluded to this previously).

No ... we jump down to ia64_os_mca_proc_state_dump that saves a lot
of stuff ... but not apparently the right stuff.

-Tony
