From: Gwenole Beauchesne <gbeauchesne@mandrakesoft.com>
Date: Sat, 12 Jan 2002 11:06:40 +0000
Subject: Re: [Linux-ia64] pre-built Mozilla 0.9.7 anyone?
Message-Id: <marc-linux-ia64-105590698805818@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805758@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805758@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Mon, 7 Jan 2002, David Mosberger wrote:

> Does anyone have a pre-built version of Mozilla 0.9.7 somewhere?

As "usual", you can find them here:
<https://qa.mandrakesoft.com/~gb/ia64/mozilla/>

That time, I could not make it work with decent optimizations at all. This
is likely to be a bug in the compiler, but I had tried with both "2.96"
and 3.0.3. With the latter, packages won't even fully build.

BTW, David, have you noticed an unaligned access for "regxpcom" with your
build ? regxpcom issues an unaligned access with the 0.9.7 version I have
just built but does nothing with 0.9.4-4.4mdk that is available on
Mandrake Linux 8.1/Itanium. Probably nothing critical but that sounds a
regression in the Mozilla code ?

Sorry but I don't have much time to investigate more so, I will move the
above mentioned packages to unsupported/ia64.

Bye,
Gwenole.


