From: "David A. Wheeler" <dwheeler@dwheeler.com>
Date: Fri, 22 Apr 2005 03:30:18 +0000
Subject: Re: ia64 git pull
Message-Id: <42686FCA.2010605@dwheeler.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200504212042.j3LKgng04318@unix-os.sc.intel.com>	<Pine.LNX.4.58.0504211403080.2344@ppc970.osdl.org>	<200504212155.j3LLtho04949@unix-os.sc.intel.com>	<200504212301.j3LN1Do05507@unix-os.sc.intel.com>	<20050422012546.GD1474@pasky.ji.cz>	<17000.22515.170455.192374@sodium.jf.intel.com>	<20050422015340.GD7443@pasky.ji.cz> <17000.23588.462823.574142@sodium.jf.intel.com>
In-Reply-To: <17000.23588.462823.574142@sodium.jf.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Inaky Perez-Gonzalez <inaky@linux.intel.com>
Cc: Petr Baudis <pasky@ucw.cz>, tony.luck@intel.com, Linus Torvalds <torvalds@osdl.org>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, git@vger.kernel.org

Petr Baudis <pasky@ucw.cz> writes:
>>Still, why would you escape it? My shell will not take # as a
>>comment start if it is immediately after an alphanumeric character.

I guess there MIGHT be some command shell implementation
that stupidly _DID_ accept "#" as a comment character,
even immediately after an alphanumeric.
If that's true, then using # there would be a pain for portability.

But I think that's highly improbable.  A quick peek
at the Single Unix Specification as posted by the Open Group
seems to say that, according to the standards, that's NOT okay:
http://www.opengroup.org/onlinepubs/009695399/utilities/xcu_chap02.html#tag_02
Basically, the command shell is supposed to tokenize, and "#"
only means comment if it's at the beginning of a token.

And as far as I can tell, it's not an issue in practice either.
I did a few quick tests on Fedora Core 3 and OpenBSD.
On Fedora Core 3, I can say that bash, ash & csh all do NOT
consider "#" as a comment start if an alpha precedes it.
The same is true for OpenBSD /bin/sh, /bin/csh, and /bin/rksh.
If such different shells do the same thing (this stuff isn't even
legal C-shell text!), it's likely others do too.

--- David A. Wheeler
