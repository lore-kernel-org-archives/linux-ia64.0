From: Mark Fasheh <mfasheh@suse.com>
Date: Wed, 29 Oct 2008 21:39:02 +0000
Subject: Re: linux-next: Tree for October 28
Message-Id: <20081029213902.GF15154@wotan.suse.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20081028183055.fbcf5420.sfr@canb.auug.org.au> <20081028220741.f5d331ba.akpm@linux-foundation.org>
In-Reply-To: <20081028220741.f5d331ba.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Stephen Rothwell <sfr@canb.auug.org.au>, linux-next@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, linux-ia64@vger.kernel.org, Ingo Molnar <mingo@elte.hu>, Steven Rostedt <rostedt@goodmis.org>, linux-wireless@vger.kernel.org, Joel Becker <Joel.Becker@oracle.com>

On Tue, Oct 28, 2008 at 10:07:41PM -0700, Andrew Morton wrote:
> plus of course enough compile warnings to start a small war.   ocfs2 is
> prominent.
> 
> fs/ocfs2/xattr.c: In function `ocfs2_xattr_index_block_find':
> fs/ocfs2/xattr.c:2338: warning: long long unsigned int format, u64 arg (arg 7)
> fs/ocfs2/xattr.c:2338: warning: long long unsigned int format, u64 arg (arg 7)
> fs/ocfs2/xattr.c:2338: warning: long long unsigned int format, u64 arg (arg 7)

Thanks for pointing these out Andrew. They slipped by me. I'll get them
fixed up before the conflict escalates  ;)
	--Mark

--
Mark Fasheh
