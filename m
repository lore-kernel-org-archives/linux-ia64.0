From: Jim Wilson <wilson@cygnus.com>
Date: Fri, 07 Jul 2000 19:50:04 +0000
Subject: Re: [Linux-ia64] Re: gas dependency checker bug [forwarded message from Xavier Leroy]
Message-Id: <marc-linux-ia64-105590678205191@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205190@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205190@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

The assembler DV support is in a funny state at the moment.  Intel has run
gas through their DV testsuite, identified a number of bugs, and wrote patches
for them.  Unfortunately, I can't use the Intel patches without FSF copyright
assignments, and it isn't clear when this issue will be resolved.  Meanwhile,
Red Hat doesn't have anyone actively working on the assembler, so we are
waiting to see if we can use the Intel patches, and we will probably wait
quite a while before giving up and doing the work ourselves.

Jim


