From: James E Wilson <wilson@tuliptree.org>
Date: Wed, 23 Nov 2005 06:02:37 +0000
Subject: RE: Fix asm constraint in put_user
Message-Id: <1132725693.31498.108.camel@aretha.corp.specifix.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <je7jb2nigc.fsf@sykes.suse.de>
In-Reply-To: <je7jb2nigc.fsf@sykes.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Mon, 2005-11-21 at 14:11, Luck, Tony wrote:
> So should I go with the original patch using "r"?

Yes.  It should work fine.  Meanwhile, I'm trying to look at the
compiler issues in the hope of providing a better solution in the
future.



