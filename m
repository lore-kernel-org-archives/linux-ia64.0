From: "H. J. Lu" <hjl@lucon.org>
Date: Wed, 15 Oct 2003 22:53:35 +0000
Subject: Re: WAW dependency messages
Message-Id: <marc-linux-ia64-106625857220335@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106625678318659@msgid-missing>
In-Reply-To: <marc-linux-ia64-106625678318659@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, Oct 15, 2003 at 03:24:34PM -0700, Jesse Barnes wrote:
> In case anyone's interested, I just found a gcc bugzilla bug for the
> dependency violation stuff that always gets printed when we compile the
> kernel.  I've added some information to it.  The bug number is 12287,
> and you can see the whole thing at
> http://gcc.gnu.org/bugzilla/show_bug.cgi?id287.
> 

I am working on some DV problems in assembler. With the new assembler,
there are fewer DV warnings when compiling 2.4.21 kernel. If someone
sends me small asm testcases, I will look into them.


H.J.
