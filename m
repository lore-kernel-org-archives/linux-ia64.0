From: mbp@sourcefrog.net
Date: Sun, 24 Aug 2003 02:19:16 +0000
Subject: Re: cross compiling ia64!
Message-Id: <marc-linux-ia64-106169164303016@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106154319501965@msgid-missing>
In-Reply-To: <marc-linux-ia64-106154319501965@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Fri, Aug 22, 2003 at 02:35:43PM +0530, Ameya Mitragotri wrote:
> Hi,
> I have been trying ,rather unsuccessfully, to cross compile the linux
> kernel 2.6-test3 using the compiler inside the NUE 1.2.

As Jim said, NUE is very old.  I have had good results using the
procedure described here:

  http://www.gelato.unsw.edu.au/IA64wiki/CrossCompilation

You might also try distcc <distcc.samba.org>.  Cross compiling is
quite slow; distcc makes it more pleasant.
 
-- 
Martin
