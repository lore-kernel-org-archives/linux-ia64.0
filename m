From: Grant Grundler <iod00d@hp.com>
Date: Sat, 29 May 2004 05:21:49 +0000
Subject: Re: lib64 in fedora glibc
Message-Id: <20040529052149.GA3177@cup.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040528214105.GK9115@mustard.zk3.dec.com>
In-Reply-To: <20040528214105.GK9115@mustard.zk3.dec.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Fri, May 28, 2004 at 11:33:36PM -0400, Aron Griffis wrote:
> > So I guess the question is what would make %%{_lib} be defined as lib64.
> 
> Right, that's why I suggested it appears they're preparing for the
> transition. 

"the transition" might be necessary to support x86_64.
Ie most of user space is 32-bit (using /lib) but some apps
will run substantially better as native x86_64 binaries.
Moving to lib32 and lib64 makes sense in that environment.

Hypothetically, it shouldn't matter for ia64 if /lib
is an alias for /lib64. Or do I see that wrong?
I thought ia64 already has from /lib32-like thing to
support ia32 binaries but I'm not the tool chain expert.

grant
