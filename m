From: Peter Chubb <peter@chubb.wattle.id.au>
Date: Mon, 28 Apr 2003 11:19:48 +0000
Subject: Re: [Linux-ia64] building an ia64 cross toolchain on debian?
Message-Id: <marc-linux-ia64-105590723705615@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705612@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705612@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> "Martin" = Martin Pool <mbp@samba.org> writes:

Martin> There seems to be a problem that the cross libc produced by
Martin> "tpkg-install-libc ia64-unknown-linx" wants to install into
Martin> /usr/ia64-linux (sic) whereas the binutils install into
Martin> /usr/ia64-unknown-linux.  I think this was causing gcc to be
Martin> unable to find the header files.


Yes,I found that too.  Version 3.2-7 of the toolchain source didn't
have the problem; an earlier version did; so I thought it was solved
and removed the instructions for working around the problem from the Wiki.

Please feel free to edit the WiKi with any workarounds you needed.
The bad version of flex was released after I last tested the
instructions -- I've logged a bug against binutils, as the native
driver can't build either at present.

--
Dr Peter Chubb     http://www.gelato.unsw.edu.au  peterc@gelato.unsw.edu.au
You are lost in a maze of BitKeeper repositories,   all slightly different.




