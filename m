From: "Luck, Tony" <tony.luck@intel.com>
Date: Thu, 24 Mar 2005 22:07:42 +0000
Subject: RE: syscall improvement patch [0/12]
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F03245CFD@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200503240049.j2O0n91k022256@napali.hpl.hp.com>
In-Reply-To: <200503240049.j2O0n91k022256@napali.hpl.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>That's very strange.  The branch-prediction may or may not help,
>depending on your test program.  The srlz.d elimination definitely
>should help, though.  What test-program are you using?  Also, are you
>using McKinley or Madison?

Madison ... but it might be an oddball stepping (it is very old).  I have
a home-grown test that reads ar.itc before/after the getpid() and saves the
difference in an array.  The program repeats 1000 times, then prints the min,
max and median number of cycles.

-Tony
