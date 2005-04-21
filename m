From: Linus Torvalds <torvalds@osdl.org>
Date: Thu, 21 Apr 2005 22:29:07 +0000
Subject: Re: ia64 git pull
Message-Id: <Pine.LNX.4.58.0504211520250.2344@ppc970.osdl.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <200504212042.j3LKgng04318@unix-os.sc.intel.com>
 <Pine.LNX.4.58.0504211403080.2344@ppc970.osdl.org>
 <200504212155.j3LLtho04949@unix-os.sc.intel.com>
In-Reply-To: <200504212155.j3LLtho04949@unix-os.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: tony.luck@intel.com
Cc: linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org



On Thu, 21 Apr 2005 tony.luck@intel.com wrote:
> 
> I can't quite see how to manage multiple "heads" in git.  I notice that in
> your tree on kernel.org that .git/HEAD is a symlink to heads/master ...
> perhaps that is a clue.

It's mainly a clue to bad practice, in my opinion. I personally like the 
"one repository, one head" approach, and if you want multiple heads you 
just do multiple repositories (and you can then mix just the object 
database - set your SHA1_FILE_DIRECTORY environment variable to point to 
the shared object database, and you're good to go). 

But yes, if you want to mix heads in the same repo, you can do so, but
it's a bit dangerous to switch between them, since you'll have to blow any
dirty state away, or you end up having checked-out state that is
inconsistent with the particular head you're working on.

Switching a head is pretty easy from a _technical_ perspective: make sure 
your tree is clean (ie fully checked in), and switch the .git/HEAD symlink 
to point to a new head. Then just do

	read-tree .git/HEAD
	checkout-cache -f -a

and you're done. Assuming most checked-out state matches, it should be 
basically instantaneous.

Oh, and you may want to check that yoy didn't have any files that are now 
stale, using "show-files --others" to show what files are _not_ being 
tracked in the head you just switched to.

I think Pasky has helper functions for doing this, but since I think 
multiple heads is really too confusing for mere mortals like me, I've not 
looked at it.

> I'd like to have at least two, or perhaps even three "HEADS" active in my
> tree at all times.  One would correspond to my old "release" tree ... pointing
> to changes that I think are ready to go into the Linus tree.  A second would
> be the "testing" tree ... ready for Andrew to pull into "-mm", but not ready
> for the base. The third (which might only exist in my local tree) would be
> for changes that I'm playing around with.

I _really_ suggest having separate directories and not play with heads. 

As shown above, git can technically support what you're doing very
efficiently, but the problem is not technology - it's user confusion. It's
just too damn easy to do the wrong thing if you end up using the same
directory for all your heads, and switch between them.

In contrast, having separate directories, all with their own individual 
heads, you are much more likely to know what you're up to by just getting 
the hints from the environment.

		Linus
