From: Jim Wilson <wilson@cygnus.com>
Date: Fri, 23 Mar 2001 07:13:14 +0000
Subject: Re: [Linux-ia64] gcc-ia64 latest distributions
Message-Id: <marc-linux-ia64-105590693005345@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590693005332@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590693005332@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

I used to maintain a copy of gcc sources on ftp.cygnus.com, but that machine
has been down for 2 weeks now, and I haven't gotten any answer as to when it
will be back up.  That version of gcc was getting pretty old though, and
wasn't being actively maintained anymore.

If you have any recent OS distribution from any Linux vendor, then you can
get a good copy of gcc from there.  They all have source RPMS of gcc, which are
all pretty much the same compiler that I was maintaining on ftp.cygnus.com.
For instance, on ftp.redhat.com, or any mirror, you can find this in
/pub/redhat/beta/fisher/en/SRPMS/ia64/SRPMS/gnupro-1117-6.src.rpm

If you want a completely up-to-date copy of gcc, then you have to get it
from the FSF.
For gcc: <http://gcc.gnu.org>
For binutils (as/ld/etc): <http://sources.redhat.com/binutils>
However, these are development versions, and if you use them, you
need to be prepared to deal with occasional instabilities.  Also, there
are some known bugs that need to be fixed before these will be widely used.
E.g. there are kernel miscompilation problems to fix.

Jim


