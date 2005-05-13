From: "H. J. Lu" <hjl@lucon.org>
Date: Fri, 13 May 2005 21:58:15 +0000
Subject: Re: PATCH: Don't allow ia64 unwind section to point to section in different files
Message-Id: <20050513215815.GA32009@lucon.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20050513214612.GA31765@lucon.org>
In-Reply-To: <20050513214612.GA31765@lucon.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Fri, May 13, 2005 at 02:46:12PM -0700, H. J. Lu wrote:
> On Fri, May 13, 2005 at 02:05:56PM -0700, David Mosberger wrote:
> > >>>>> On Fri, 13 May 2005 14:01:11 -0700, "H. J. Lu" <hjl@lucon.org> said:
> > 
> >   >> However, there still seems to be a binutils issues here: if this
> >   >> is something binutils cannot properly support, it should issue an
> >   >> error, not silently generate wrong code, no?
> > 
> >   HJ> I will see what I can do.
> > 
> 
> When weak functions are used on ia64, part of the unwind section may
> point to the strong definition in a different file. This will lead to
> wrong unwind info. Basically, on ia64, we have to use comdat to get the
> right unwind info. This patch will check it.
> 
> 

Well, it isn't very useful. The problem is libc.a has many weak
functions and user can override them. My patch will make it impossible
on ia64. I guess we may have to live with the imperfect unwind info
when weak functions are used. The unwinder may have to deal with it.


H.J.
