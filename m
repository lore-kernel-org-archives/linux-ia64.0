From: "Luck, Tony" <tony.luck@intel.com>
Date: Thu, 13 May 2004 09:02:44 +0000
Subject: RE: [RFC] I/O MCA recovery
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F013CCE07@scsmsx401.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200405040954.09524.jbarnes@engr.sgi.com>
In-Reply-To: <200405040954.09524.jbarnes@engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>There are also locking problems, since at the moment an MCA 
>could occur on multiple processors, but I think the MCA code
>in general doesn't handle that case...

At the moment the MCA code serializes simulaneous MCA on multiple
processors (see the hand-crafted spinlock in mca_asm.S at the
ia64_os_mca_spin label).

-Tony
