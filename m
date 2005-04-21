From: Petr Baudis <pasky@ucw.cz>
Date: Thu, 21 Apr 2005 22:58:57 +0000
Subject: Re: ia64 git pull
Message-Id: <20050421225857.GB1474@pasky.ji.cz>
List-Id: <linux-ia64.vger.kernel.org>
References: <200504212042.j3LKgng04318@unix-os.sc.intel.com> <Pine.LNX.4.58.0504211403080.2344@ppc970.osdl.org> <200504212155.j3LLtho04949@unix-os.sc.intel.com> <Pine.LNX.4.58.0504211520250.2344@ppc970.osdl.org>
In-Reply-To: <Pine.LNX.4.58.0504211520250.2344@ppc970.osdl.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Linus Torvalds <torvalds@osdl.org>
Cc: tony.luck@intel.com, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, git@vger.kernel.org

Dear diary, on Fri, Apr 22, 2005 at 12:29:07AM CEST, I got a letter
where Linus Torvalds <torvalds@osdl.org> told me that...
> On Thu, 21 Apr 2005 tony.luck@intel.com wrote:
> > 
> > I can't quite see how to manage multiple "heads" in git.  I notice that in
> > your tree on kernel.org that .git/HEAD is a symlink to heads/master ...
> > perhaps that is a clue.
> 
> It's mainly a clue to bad practice, in my opinion. I personally like the 
> "one repository, one head" approach, and if you want multiple heads you 
> just do multiple repositories (and you can then mix just the object 
> database - set your SHA1_FILE_DIRECTORY environment variable to point to 
> the shared object database, and you're good to go). 

There are two points regarding this:

(i) You need to track heads of remote branches anyway.

(ii) I want an easy way for user to refer to head of another working
tree on the same repository (so that you can do just git merge testing).

This is why the multiple heads are there, and it's actually everything
they _do_. There's nothing more behind it.

-- 
				Petr "Pasky" Baudis
Stuff: http://pasky.or.cz/
C++: an octopus made by nailing extra legs onto a dog. -- Steve Taylor
