From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Thu, 24 Mar 2005 22:25:51 +0000
Subject: RE: syscall improvement patch [0/12]
Message-Id: <16963.15983.951132.586843@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200503240049.j2O0n91k022256@napali.hpl.hp.com>
In-Reply-To: <200503240049.j2O0n91k022256@napali.hpl.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Thu, 24 Mar 2005 14:07:42 -0800, "Luck, Tony" <tony.luck@intel.com> said:

  >> That's very strange.  The branch-prediction may or may not help,
  >> depending on your test program.  The srlz.d elimination
  >> definitely should help, though.  What test-program are you using?
  >> Also, are you using McKinley or Madison?

  Tony> Madison ... but it might be an oddball stepping (it is very
  Tony> old).  I have a home-grown test that reads ar.itc before/after
  Tony> the getpid() and saves the difference in an array.  The
  Tony> program repeats 1000 times, then prints the min, max and
  Tony> median number of cycles.

Oh, getpid() probably doesn't do anything in your case.  You can
verify with strace.  If you see only a single getpid() syscall, your
libc is caching the getpid return value (I don't think glibc _ought_
to be caching getpid(), but it does...).  Try getuid() instead.

	--david
