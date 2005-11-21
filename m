From: James E Wilson <wilson@tuliptree.org>
Date: Mon, 21 Nov 2005 19:03:15 +0000
Subject: Re: Fix asm constraint in put_user
Message-Id: <1132598855.9319.39.camel@aretha.corp.specifix.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <je7jb2nigc.fsf@sykes.suse.de>
In-Reply-To: <je7jb2nigc.fsf@sykes.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Mon, 2005-11-21 at 07:12, Andreas Schwab wrote:
> The st insn on the ia64 does not allow the post-increment to come from a
> register (only ld does).  Thus the "m" constraint is not suitable for the
> asm statement in __put_user_size.

You could use the "S" constraint here.  This isn't used anywhere in
gcc.  This exists solely for use by asms that need a non-postinc MEM.



