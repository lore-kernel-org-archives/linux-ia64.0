From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Mon, 24 Jan 2005 17:51:12 +0000
Subject: Re: optimize __gp location
Message-Id: <16885.13712.911861.609179@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <B05667366EE6204181EABE9C1B1C0EB50589FCE9@scsmsx401.amr.corp.intel.com>
In-Reply-To: <B05667366EE6204181EABE9C1B1C0EB50589FCE9@scsmsx401.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Fri, 21 Jan 2005 15:22:18 -0800, "Chen, Kenneth W" <kenneth.w.chen@intel.com> said:

  Ken> Can we position the __gp somewhat more optimally, to cover more of these
  Ken> symbols? Something like the following patch would make all of them fall
  Ken> into the 22-bit immediate offset relative to gp.

The position was chosen to maximize the amount of data that can be
addressed via the GOT.  As you observe, that doesn't maximize the
amount of data that can be addressed in a GP-relative fashion.

It might be best to just remove the __gp definition.  In that case,
the linker will automatically choose a value and it ought to be able
to choose an optimal value.

	--david
