From: Erich Focht <efocht@hpce.nec.com>
Date: Wed, 24 Sep 2003 22:27:58 +0000
Subject: Re: CPUSET Proposal
Message-Id: <marc-linux-ia64-106444292719248@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106441927021899@msgid-missing>
In-Reply-To: <marc-linux-ia64-106441927021899@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thursday 25 September 2003 00:06, David Mosberger wrote:
> BTW: What do cpusets provide that couldn't be done with user-level
> tools on top of the existing sched_setaffinity() system call?

You've got one point here. As the cpumasks are inherited, you'd just
have to make sure that a user cannot escape his cpuset by e.g. not
allowing the mask to get bigger than the mask of the parent process
(which can be owned by root, thus unchangeable). The management of the
cpusets can then be taken over by a user space daemon.

Erich


