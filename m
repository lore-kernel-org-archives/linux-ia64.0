From: Nathan Straz <nstraz@sgi.com>
Date: Wed, 25 Sep 2002 18:35:43 +0000
Subject: Re: [Linux-ia64] platform detection at run-time
Message-Id: <marc-linux-ia64-105590701906052@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701906051@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701906051@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, Sep 25, 2002 at 02:18:51PM -0400, Sane_Purushottam@emc.com wrote:
> What is the preferred method to determine the platform at run time ?? Are
> these values likely to change (after I change my code to handle this) ????

I had to do the same thing for an application and I ended up forking off
a process to run the uname command.  
-- 
Nate Straz                                              nstraz@sgi.com
sgi, inc                                           http://www.sgi.com/
Linux Test Project                                  http://ltp.sf.net/

