From: "H. J. Lu" <hjl@lucon.org>
Date: Mon, 16 May 2005 13:58:22 +0000
Subject: Re: PATCH: Don't allow ia64 unwind section to point to section in different files
Message-Id: <20050516135821.GA2538@lucon.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20050513214612.GA31765@lucon.org>
In-Reply-To: <20050513214612.GA31765@lucon.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Mon, May 16, 2005 at 02:26:36AM -0700, David Mosberger wrote:
> >>>>> On Fri, 13 May 2005 14:58:15 -0700, "H. J. Lu" <hjl@lucon.org> said:
> 
>   HJ> Well, it isn't very useful. The problem is libc.a has many weak
>   HJ> functions and user can override them. My patch will make it
>   HJ> impossible on ia64. I guess we may have to live with the
>   HJ> imperfect unwind info when weak functions are used. The unwinder
>   HJ> may have to deal with it.
> 
> Huh?  How do you propose it deal with it?
> 
> Wrong unwind info will break exception handling.  I don't think that's
> acceptable.

Since the weak function is still in the executable, its unwind info is
also there. That is what you see in kernel.


H.J.
