From: "Luck, Tony" <tony.luck@intel.com>
Date: Wed, 01 Sep 2004 05:25:31 +0000
Subject: RE: [Patch] Per CPU MCA/INIT data save areas
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F01F0996E@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200408312112.i7VLCPc9002392@ben.americas.sgi.com>
In-Reply-To: <200408312112.i7VLCPc9002392@ben.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

+	addl	r2 = THIS_CPU(cpu_info) + IA64_CPUINFO_MCA_DATA,r0;;
+	ld8	r2=[r2];;	// r2 pointing to top of this cpu's MCA/INIT save area

Does this work?  MCA and INIT are called in physical mode
(with psr.dt = 0) ... so I think you'll just choke here
when you deref the percpu address.

-Tony
