From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Mon, 14 Feb 2005 19:17:37 +0000
Subject: RE: [rfc] generic allocator and mspec driver
Message-Id: <16912.63825.410701.32927@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <16897.9640.160896.31584@jaguar.mkp.net>
In-Reply-To: <16897.9640.160896.31584@jaguar.mkp.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Mon, 14 Feb 2005 11:12:54 -0800, "Luck, Tony" <tony.luck@intel.com> said:

  Tony> If so, the PG_arch_1 might have to be the solution

Note that PG_arch_1 is already being used as a "i-cache coherent" flag.

	--david
