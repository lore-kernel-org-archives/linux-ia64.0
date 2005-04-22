From: Inaky Perez-Gonzalez <inaky@linux.intel.com>
Date: Fri, 22 Apr 2005 02:06:28 +0000
Subject: Re: ia64 git pull
Message-Id: <17000.23588.462823.574142@sodium.jf.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200504212042.j3LKgng04318@unix-os.sc.intel.com>
	<Pine.LNX.4.58.0504211403080.2344@ppc970.osdl.org>
	<200504212155.j3LLtho04949@unix-os.sc.intel.com>
	<200504212301.j3LN1Do05507@unix-os.sc.intel.com>
	<20050422012546.GD1474@pasky.ji.cz>
	<17000.22515.170455.192374@sodium.jf.intel.com>
	<20050422015340.GD7443@pasky.ji.cz>
In-Reply-To: <20050422015340.GD7443@pasky.ji.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Petr Baudis <pasky@ucw.cz>
Cc: tony.luck@intel.com, Linus Torvalds <torvalds@osdl.org>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, git@vger.kernel.org

>>>>> Petr Baudis <pasky@ucw.cz> writes:

> Remember that it's an URL (so you can't use '%'), and '#' is the
> canonical URL fragment identifier delimiter. (And fragments are
> perfect for this kind of thing, if you look at the RFC, BTW.)

Ouch, true--rule out %...

> Still, why would you escape it? My shell will not take # as a
> comment start if it is immediately after an alphanumeric character.

Well, you just taught me something about bash I didn't know....

/me goes back to his hole with some more knowledge.

Thanks,

-- 

Inaky

