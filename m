From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Date: Wed, 26 Jan 2005 21:54:21 +0000
Subject: RE: syscall exit path optimization
Message-Id: <200501262154.j0QLsMg28499@unix-os.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200501262102.j0QL2Qg28166@unix-os.sc.intel.com>
In-Reply-To: <200501262102.j0QL2Qg28166@unix-os.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

David Mosberger wrote on Wednesday, January 26, 2005 1:31 PM
> I like the patch (it's quite clever!), except it would be nice if we
> could avoid the p8/p9 dependencies.  Couldn't you restore r8/r10 after
> .work_pending is done in if pLvSys is TRUE?  That way, .work_processed
> would simply preserve (save _and_ restore) r8/r10.

Yeah, I think that's doable.

- Ken


