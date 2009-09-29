From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Tue, 29 Sep 2009 18:07:40 +0000
Subject: RE: [git pull] ia64 changes
Message-Id: <alpine.LFD.2.01.0909291100560.6996@localhost.localdomain>
List-Id: <linux-ia64.vger.kernel.org>
References: <1FE6DD409037234FAB833C420AA843EC0122AEB1@orsmsx424.amr.corp.intel.com>
In-Reply-To: <1FE6DD409037234FAB833C420AA843EC0122AEB1@orsmsx424.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org



On Tue, 29 Sep 2009, Luck, Tony wrote:
> 
> What will be the big areas of growth? dentry? inode? Something off
> in networking?

I'd pick dentry, but I'm biased (I happen to think the dcache is one of 
the most important data structures we have). Right now, in x86-64, we lay 
out the spinlock along with the other int-sized things, and we've tried to 
pack things over the years (ie put the commonly accessed ones together). 

See for example commit c2452f32786159ed85f0e4b21fec09258f822fc8.

I do agree that none of the static spinlocks care about size, obviously. 
The only time the size of a spinlock matters is when it's embedded in one 
of the critical common data structures. And in _many_ cases you'll have 
pointers there that end up forcing it to 64-bit, but 'struct dentry' is an 
example of something where things can be (and are) more densely packed, 
and people have spent some time on it.

		Linus
