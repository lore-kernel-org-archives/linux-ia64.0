From: Bill Nottingham <notting@redhat.com>
Date: Fri, 04 Jun 2004 19:23:19 +0000
Subject: Re: lib64 in fedora glibc
Message-Id: <20040604192319.GF3454@nostromo.devel.redhat.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040528214105.GK9115@mustard.zk3.dec.com>
In-Reply-To: <20040528214105.GK9115@mustard.zk3.dec.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

David Mosberger (davidm@napali.hpl.hp.com) said: 
>   Andreas> I don't know what Red Hat is doing with x86 and with lib64 - and you
>   Andreas> really should ask them for clarification.
> 
> Certainly.  I only wished Red Hat would be more
> willing/interested/active in discussing such things on public mailing
> lists.

Where this came out of was requests from various partners and ISVs
who noticed that their 32-bit apps didn't run right on ia64 with
the /emul/ia32-linux prefix. This is due to some of the fundamental
issues with that arrangement:

- 64-bit processes don't see into that tree because of their personality
  (think: shell scripts)
- the results of readdir() on a directory in /emul/ia32-linux will not
  necessarily match the files you can actually access with open()

The simplest way to solve this, while maintaining compatiblity with
ia32 packages, is to get them on the same filesystem. This is where
the proposal stemmed from, originally.

We can always just live with crappy ia32 (and by extension,
x86-64) support on ia64. :)

Bill
