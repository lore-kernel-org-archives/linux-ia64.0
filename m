From: Jes Sorensen <jes@wildopensource.com>
Date: Mon, 20 Oct 2003 08:34:35 +0000
Subject: Re: [patch] xbow.c kmalloc fixes
Message-Id: <marc-linux-ia64-106663954514393@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106641220628729@msgid-missing>
In-Reply-To: <marc-linux-ia64-106641220628729@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> "Colin" = Colin Ngam <cngam@sgi.com> writes:

Colin> It does not matter to me if you want us to wait until this
Colin> code-fixes-only period is over.  We will be doing all our
Colin> regression on 2.4 and when we merge over to 2.6, we will also
Colin> do our regression tests there too.  None of these changes will
Colin> have any effect on any other platform except to ensure that
Colin> Generic builds and boots on other Platforms(including SGI).

Hi Colin,

I think we need to get moving on the 2.6 push asap, the 2.6 tree is
closing soon so we need to get it in as soon as possible ot we risk
missing the train.

I don't think the new hardware supports is as big a problem to put in
later since it's always legal to push new 'drivers' to a stable
kernel.

Cheers,
Jes
