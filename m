From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Mon, 14 Jan 2002 21:51:24 +0000
Subject: Re: [Linux-ia64] pre-built Mozilla 0.9.7 anyone?
Message-Id: <marc-linux-ia64-105590698805821@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805758@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805758@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Mon, 14 Jan 2002 13:33:16 -0800, David Mosberger <davidm@napali.hpl.hp.com> said:

  David> The snapshot built with gcc3.0 fine (using -O as usual).  I
  David> just started a build with gcc 3.1 (pre-release).

Well, that didn't go too well: with gcc3.1 (experimental), the build
crashes very early on when trying to run xpidl.  Looks to me like bad
code is being generated, though I have not had time to look closer.

	--david

