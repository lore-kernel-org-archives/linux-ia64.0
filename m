From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Wed, 06 Mar 2002 20:22:16 +0000
Subject: Re: [Linux-ia64] psr.dt state when DO_SAVE_MIN is invoked
Message-Id: <marc-linux-ia64-105590701905233@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701905232@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701905232@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Wed, 6 Mar 2002 11:45:38 -0800, "Luck, Tony" <tony.luck@intel.com> said:

  Tony> See how page_fault explicitly sets psr.dt, and then invokes a
  Tony> macro that says that the assumed entry state is psr.dt should
  Tony> be off. Is the comment just plain wrong, or is there a
  Tony> potential issue here?

The comment is wrong.  It used to be correct, but when the MC folks
changed the code to do the min save through virtual space, the comment
apparently wasn't updated.  I'll fix this.

Thanks,

	--david

