From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Thu, 24 Mar 2005 21:39:31 +0000
Subject: RE: syscall improvement patch [0/12]
Message-Id: <16963.13203.782739.451294@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200503240049.j2O0n91k022256@napali.hpl.hp.com>
In-Reply-To: <200503240049.j2O0n91k022256@napali.hpl.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Thu, 24 Mar 2005 13:36:43 -0800, "Luck, Tony" <tony.luck@intel.com> said:

  Tony> Ok ... these changes are in my test-2.6.12 tree.  I'm not
  Tony> seeing any improvement in the epc path though (running with
  Tony> SLES9 toolchain).

That's very strange.  The branch-prediction may or may not help,
depending on your test program.  The srlz.d elimination definitely
should help, though.  What test-program are you using?  Also, are you
using McKinley or Madison?

	--david
