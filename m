From: Pavel Machek <pavel@ucw.cz>
Date: Sun, 19 Oct 2003 18:17:57 +0000
Subject: Re: [RFC] prevent "dd if=/dev/mem" crash
Message-Id: <marc-linux-ia64-106689678007419@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106642876514553@msgid-missing>
In-Reply-To: <marc-linux-ia64-106642876514553@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi!

> > Old behavior:
> > 
> >     # dd if=/dev/mem of=/dev/null
> >     <unrecoverable machine check>
> 
> I recently fixed this for ia32 by changing copy_to_user() to not oops if
> the source address generated a fault.  Similarly copy_from_user() returns
> an error if the destination generates a fault.

Are you sure this is not hiding real errors? If you pass wrong
kernel ptr to copy_*_user, it should oops, not mask error with
-EFAULT.
Maybe another copy_user_unsafe should be created?
				Pavel
-- 
				Pavel
Written on sharp zaurus, because my Velo1 broke. If you have Velo you don't need...

