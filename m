From: James E Wilson <wilson@tuliptree.org>
Date: Wed, 23 Nov 2005 22:08:24 +0000
Subject: Re: Fix asm constraint in put_user
Message-Id: <1132783704.9295.21.camel@aretha.corp.specifix.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <je7jb2nigc.fsf@sykes.suse.de>
In-Reply-To: <je7jb2nigc.fsf@sykes.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Mon, 2005-11-21 at 13:26, Andreas Schwab wrote:
> James E Wilson <wilson@tuliptree.org> writes:
> > You could use the "S" constraint here.  This isn't used anywhere in
> > gcc.  This exists solely for use by asms that need a non-postinc MEM.
> Alas, it does not work:
> sound/oss/rme96xx.c:744: error: 'asm' operand requires impossible reload

This is now FSF GCC PR 25008.
    http://gcc.gnu.org/bugzilla/show_bug.cgi?id%008

And lack of a proper constraint letter for a store destination is FSF
GCC PR 24961 which you filed.
    http://gcc.gnu.org/bugzilla/show_bug.cgi?id$961


