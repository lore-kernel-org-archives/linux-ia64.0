From: Andrew Morton <akpm@linux-foundation.org>
Date: Fri, 16 Jan 2009 22:15:57 +0000
Subject: Re: linux-next: build problem with nfs tree (Was: Re:
Message-Id: <20090116141557.0a3eaaac.akpm@linux-foundation.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20090115200315.EBE3.KOSAKI.MOTOHIRO@jp.fujitsu.com>
	<20090115093514.f3f6b8ff.akpm@linux-foundation.org>
	<20090116124949.7828a559.sfr@canb.auug.org.au>
	<20090115175917.8e0ae536.akpm@linux-foundation.org>
	<20090116134930.68e783aa.sfr@canb.auug.org.au>
	<20090116153417.891297ca.sfr@canb.auug.org.au>
In-Reply-To: <20090116153417.891297ca.sfr@canb.auug.org.au>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Stephen Rothwell <sfr@canb.auug.org.au>
Cc: linux-next@vger.kernel.org, prarit@redhat.com, dhowells@redhat.com, kosaki.motohiro@jp.fujitsu.com, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, sam@ravnborg.org, kyle@mcmartin.ca, tony.luck@intel.com, trond.myklebust@fys.uio.no

On Fri, 16 Jan 2009 15:34:17 +1100
Stephen Rothwell <sfr@canb.auug.org.au> wrote:

> With the help of Paul Mackerras, I have come up with the shell script
> below.  You run it with the commit id, the tag of the tree you care
> about (e.g. next-20080115)(it defaults to the current top of tree) and
> the name of the branch the represents Linus' tree (default to
> origin/master).  It will spit out the (or a) tree that contains the
> commit you asked about.

hm.  Thanks.

y:/usr/src/git26> git-checkout linux-next
Switched to branch "linux-next"
y:/usr/src/git26> who-committed.sh ba9a5918
y:/usr/src/git26> who-committed.sh 2c3fb6b1b1a43ca089032e6523207f6687c962c1
y:/usr/src/git26> 
