From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Wed, 18 Jun 2003 19:00:58 +0000
Subject: Re: gcc bug
Message-Id: <marc-linux-ia64-105596286528010@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Tue, 17 Jun 2003 18:30:48 -0700, Umut Aymakoglu <umuta@us.ibm.com> said:

  Umut> Hi -
  Umut> Below is a small repro which shows the bug and the output that I get. Is
  Umut> this a known bug? Any help will be appreciated.

  Umut> The version of glibc :  glibc-2/2/4-32.3

The linux-ia64 list is not really the right place for reporting GCC
bugs.  Please see:

	http://gcc.gnu.org/bugs.html

for how to report GCC bugs.

You didn't mention what compiler you were using.  I tried your test
program quickly with gcc 3.2.3 and it worked fine for me.

	--david
