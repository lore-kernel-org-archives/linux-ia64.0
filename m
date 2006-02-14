From: Jes Sorensen <jes@sgi.com>
Date: Tue, 14 Feb 2006 10:04:45 +0000
Subject: git question
Message-Id: <yq08xsez26a.fsf@jaguar.mkp.net>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi,

I was trying to checkout a copy of Tony's release tree, but I get a
strange error when doing so.

Anyone know how to get around this, or is it not possible to do so?

first:
git-clone rsync://rsync.kernel.org/pub/scm/linux/kernel/git/aegl/linux-2.6.git
then:
[jes@tomahawk linux-2.6]$ git-pull
fatal: Needed a single revision
Pulling into a black hole?

???

Thanks,
Jes
