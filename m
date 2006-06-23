From: Keith Owens <kaos@sgi.com>
Date: Fri, 23 Jun 2006 00:29:17 +0000
Subject: Re: patches added to release/test trees
Message-Id: <8684.1151022557@ocs3.ocs.com.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <200601270107.k0R17838011430@agluck-lia64.sc.intel.com>
In-Reply-To: <200601270107.k0R17838011430@agluck-lia64.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Andreas Schwab (on Fri, 23 Jun 2006 02:11:55 +0200) wrote:
>Keith Owens <kaos@sgi.com> writes:
>
>> Not adding your own tags, but Linus's tags are missing from the ia64
>> tree.  For some reason, just copying .git/refs/tags from the torvalds
>> git tree does not work, git-branch complains about invalid objects.  I
>> thought that tags were portable between trees with common ancestors.
>
>You have only copied the references, but not the objects itself.  The
>easiest way to do that is to point objects/info/alternates to your copy of
>Linus' object store.

That makes sense.  But why is the ia64 git tree missing the Linus
objects and tags in the first place?

