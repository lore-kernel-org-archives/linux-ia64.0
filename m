From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Tue, 11 Mar 2003 19:20:02 +0000
Subject: [Linux-ia64] Re: bogus __clear_bit macro
Message-Id: <marc-linux-ia64-105590709806027@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Tue, 11 Mar 2003 11:01:54 -0800, "Chen, Kenneth W" <kenneth.w.chen@intel.com> said:

  Ken> David, It looks like when __clear_bit() was implemented, the
  Ken> deletion of the macro falls through the crack.  This macro
  Ken> prohibit the actual __clear_bit to be invoked.

Good catch.  Patch applied.

Thanks,

	--david

