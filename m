From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Tue, 25 Jan 2005 20:01:11 +0000
Subject: RE: optimize __gp location
Message-Id: <16886.42375.4283.435066@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <B05667366EE6204181EABE9C1B1C0EB50589FCE9@scsmsx401.amr.corp.intel.com>
In-Reply-To: <B05667366EE6204181EABE9C1B1C0EB50589FCE9@scsmsx401.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Tue, 25 Jan 2005 11:57:53 -0800, "Chen, Kenneth W" <kenneth.w.chen@intel.com> said:

  Ken> 4% of total cpu stall cycles.  6% of all memory references (in
  Ken> kernel space).  Though they are very concentrated to a few
  Ken> cache lines.

Sounds pretty promising.

	--david
