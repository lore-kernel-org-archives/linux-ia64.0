From: Nathan Straz <nstraz@sgi.com>
Date: Wed, 25 Sep 2002 18:57:38 +0000
Subject: Re: [Linux-ia64] platform detection at run-time
Message-Id: <marc-linux-ia64-105590701906057@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701906051@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701906051@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, Sep 25, 2002 at 11:48:47AM -0700, David Mosberger wrote:
> >>>>> On Wed, 25 Sep 2002 13:35:43 -0500, Nathan Straz <nstraz@sgi.com> said:
>   Nathan> I had to do the same thing for an application and I ended up
>   Nathan> forking off a process to run the uname command.
> 
> That doesn't work.  On a properly configured machine,
> execve("/bin/uname") will return i686 when execute from an x86
> process.

What are the puzzle pieces of a "properly configured machine?"  It's
worked on all Redhat 7.2 based systems I've run.  

-- 
Nate Straz                                              nstraz@sgi.com
sgi, inc                                           http://www.sgi.com/
Linux Test Project                                  http://ltp.sf.net/

