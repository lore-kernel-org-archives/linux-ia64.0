From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Fri, 12 Dec 2003 17:21:59 +0000
Subject: Re: [jakub@redhat.com: Re: [brian.j.vandecoevering@intel.com: RE: [Linux-ia64] problems with ppp/ppp
Message-Id: <marc-linux-ia64-107125003407188@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-107124350029067@msgid-missing>
In-Reply-To: <marc-linux-ia64-107124350029067@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Fri, 12 Dec 2003 10:37:16 -0500, Bill Nottingham <notting@redhat.com> said:

  Bill> Back long ago, I reported a problem with PPP on ia64:
  Bill> http://www.gelato.unsw.edu.au/linux-ia64/0105/1641.html

  Bill> We added the workaround in our tree for earlier releases, and
  Bill> promptly forgot about it; however, someone reported that RHEL
  Bill> 3 has the same issue (as we took the workaround out.)

  Bill> Jakub noticed the following - does this explain the problem?

Yes, it sure does.  Argh, passing functions to get/put-user macro
arguments.  I suppose that's legal... ;-(

  Bill> But, a function call clobbers r8.  Guess a __typeof(x) __x   Bill> (x); before __pu_err and s/x/__x/ is needed.  Probably
  Bill> __pu_addr decl should be moved before __pu_err is initialized
  Bill> too, otherwise extern int *foo (); put_user (0, foo ()); might
  Bill> not work properly.

Yeah, we need to be careful not to evalute any macro arguments while
using the special register-usage convention needed for the exception
handlers.  It affects get_user(), too.  Let me work on a patch.

	--david
