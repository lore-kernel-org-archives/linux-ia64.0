From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Thu, 25 Mar 2004 02:15:46 +0000
Subject: Re: In-Kernel NaT consumption trap when debugging highly-parallel
Message-Id: <16482.16594.284650.930351@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <16482.12999.250663.921106@wombat.chubb.wattle.id.au>
In-Reply-To: <16482.12999.250663.921106@wombat.chubb.wattle.id.au>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Thu, 25 Mar 2004 12:15:51 +1100, Peter Chubb <peter@chubb.wattle.id.au> said:

  Peter> Hi, I'm trying to debug a highly-threaded user-space program,
  Peter> but gdb is triggering NaT consumption faults in the middle of
  Peter> ptrace.

  Peter> Does anyone have any good ideas on what could be going wrong,
  Peter> and how to debug this?

Almost certainly a NULL-pointer dereference in the kernel.  I thought
I had fixed a bug were unw_access_gr() was dereferencing a NULL
nat_addr some weeks ago, when I did the ptrace fixes.  It looks like
that fix perhaps fell through the cracks or I decided no fixing was
needed after all.  What kernel are you running and how easy is it to
reproduce the bug?

	--david
