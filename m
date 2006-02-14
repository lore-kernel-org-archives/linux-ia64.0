From: Jes Sorensen <jes@sgi.com>
Date: Tue, 14 Feb 2006 13:12:47 +0000
Subject: Re: git question
Message-Id: <yq03bimytgw.fsf@jaguar.mkp.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <yq08xsez26a.fsf@jaguar.mkp.net>
In-Reply-To: <yq08xsez26a.fsf@jaguar.mkp.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> "Jes" = Jes Sorensen <jes@sgi.com> writes:

Jes> Anyone know how to get around this, or is it not possible to do
Jes> so?

Jes> first: git-clone
Jes> rsync://rsync.kernel.org/pub/scm/linux/kernel/git/aegl/linux-2.6.git
Jes> then: [jes@tomahawk linux-2.6]$ git-pull fatal: Needed a single
Jes> revision Pulling into a black hole?

Matthew suggested that I use git: of rsync: and strangely enough that
works. Baffling, but hey, I now have what I wanted ;)

Thanks,
Jes
