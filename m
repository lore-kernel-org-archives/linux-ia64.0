From: Simon Derr <Simon.Derr@bull.net>
Date: Thu, 25 Sep 2003 14:36:18 +0000
Subject: Re: CPUSET Proposal
Message-Id: <marc-linux-ia64-106450056904800@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106441927021899@msgid-missing>
In-Reply-To: <marc-linux-ia64-106441927021899@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, 24 Sep 2003, David Mosberger wrote:

> Simon,
>
> Could you please make it VERY clear that the system call numbers the
> patch is using are NOT OFFICIAL numbers and are therefore likely to
> change and/or collide unless and until they get accepted into the
> official tree?
OK, I've updated http://www.bullopensource.org/cpuset/ to highlight this,
and also added the missing userland cpuset.[ch] files, plus some more
documentation.

As suggested by Paul, maybe we'll eventually make the syscalls disappear
and replace them by some /proc interaction.

	Simon.

