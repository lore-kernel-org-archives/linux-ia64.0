From: Martin Pool <mbp@samba.org>
Date: Thu, 23 Oct 2003 08:33:16 +0000
Subject: Re: [RFC] prevent "dd if=/dev/mem" crash
Message-Id: <marc-linux-ia64-106689829008741@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106642876514553@msgid-missing>
In-Reply-To: <marc-linux-ia64-106642876514553@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On 19 Oct 2003, Pavel Machek <pavel@ucw.cz> wrote:
> Hi!
> 
> > > Old behavior:
> > > 
> > >     # dd if=/dev/mem of=/dev/null
> > >     <unrecoverable machine check>
> > 
> > I recently fixed this for ia32 by changing copy_to_user() to not oops if
> > the source address generated a fault.  Similarly copy_from_user() returns
> > an error if the destination generates a fault.
> 
> Are you sure this is not hiding real errors? If you pass wrong
> kernel ptr to copy_*_user, it should oops, not mask error with
> -EFAULT.
> Maybe another copy_user_unsafe should be created?

I think the problem is that reading memory that is mapped but doesn't
physically exist causes a Machine Check Assertion (like an NMI) rather
than a regular fault.

--
Martin
