From: Dan Pop <Dan.Pop@cern.ch>
Date: Mon, 31 Jul 2000 23:20:02 +0000
Subject: Re: [Linux-ia64] integer -> pointer question
Message-Id: <marc-linux-ia64-105590678205255@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205250@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205250@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


On Mon, 31 Jul 2000, Michael Madore wrote:

> > If you want to shut up such warnings, do what gcc suggests: cast the
> > integer to void *.
> 
> Sorry, my original post was a little unclear.  The compiler spits out a
> warning even if the programmer uses a cast.

I can't reproduce this behaviour here:

    pcpole65:~ 0 15> gcc -v
    Reading specs from /usr/local/lib/gcc-lib/ia64-unknown-linux/2.9-ia64-000216-final/specs
    gcc version 2.9-ia64-000216-final
    pcpole65:~ 0 16> cat test.c
    int main()
    {
	void *p = (void *)123;
	return 0;
    }
    pcpole65:~ 0 17> gcc test.c
    pcpole65:~ 0 18> 

But if it happens with your toolchain, the logical fix would be to cast 
the integer to long before casting it to void *.  Or, if it's a plain
integer constant, just use the 'L' suffix.  This shouldn't cause any
problems on 32-bit platforms, where int's and long's have the same size.

Dan



