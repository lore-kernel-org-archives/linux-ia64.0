From: "Luck, Tony" <tony.luck@intel.com>
Date: Wed, 04 May 2005 16:03:48 +0000
Subject: RE: catching up on the backlog
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F0366AD4D@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200505032108.j43L8wc21277@unix-os.sc.intel.com>
In-Reply-To: <200505032108.j43L8wc21277@unix-os.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>> I've picked through the list of patches in my backlog, and applied
>> this bunch to my release tree ... before I ask Linus to pull, it
>> would be useful to get some SGI testing (since the majority of the
>> changes are SGI related).
>
>Thanks to SGI we can now help with sn testing. I cloned the testing
>tree today, compiled and booted on Altix350 4way successful.

Darren,

Thanks for running the test.  I notice that you said "I cloned the
testing tree" ... which tree did you pull from?  Despite my earlier
assertion that I was going to filter things through:
  rsync://rsync.kernel.org/pub/scm/linux/kernel/git/aegl/test-2.6.git
before putting them into the release tree:
  rsync://rsync.kernel.org/pub/scm/linux/kernel/git/aegl/linux-2.6.git
that huge bunch of backlog all went into the release tree.

-Tony
